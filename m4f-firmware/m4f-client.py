#!/usr/bin/env python3
"""
BeaglePlay M4F Client
Communicates with M4F firmware via RPMsg character device

Usage:
    ./m4f-client.py ping             # Send ping command
    ./m4f-client.py status           # Get M4F status
    ./m4f-client.py echo "Hello M4F" # Echo a message
    ./m4f-client.py interactive      # Interactive mode
"""

import sys
import os
import select
import time
import argparse
from pathlib import Path

# RPMsg character device path
RPMSG_DEVICE = "/dev/rpmsg_ctrl0"
RPMSG_ENDPOINT_PREFIX = "/dev/rpmsg"


class M4FClient:
    """Client for communicating with BeaglePlay M4F core via RPMsg"""

    def __init__(self, device=None):
        """Initialize M4F client

        Args:
            device: Path to rpmsg device (auto-detected if None)
        """
        self.device = device or self._find_rpmsg_device()
        self.fd = None

    def _find_rpmsg_device(self):
        """Find available RPMsg device"""
        # Look for rpmsg character devices
        rpmsg_devices = list(Path("/dev").glob("rpmsg*"))

        if not rpmsg_devices:
            raise FileNotFoundError(
                "No RPMsg devices found. Is M4F firmware loaded?\n"
                "Try: echo start > /sys/class/remoteproc/remoteproc0/state"
            )

        # Filter out ctrl devices
        endpoint_devices = [d for d in rpmsg_devices if "ctrl" not in d.name]

        if not endpoint_devices:
            print("Available devices:", [d.name for d in rpmsg_devices])
            raise FileNotFoundError(
                "No RPMsg endpoint devices found. "
                "M4F firmware may not have created an endpoint."
            )

        device = str(endpoint_devices[0])
        print(f"Using RPMsg device: {device}")
        return device

    def connect(self):
        """Open connection to M4F"""
        try:
            self.fd = os.open(self.device, os.O_RDWR | os.O_NONBLOCK)
            print(f"Connected to M4F via {self.device}")
        except OSError as e:
            raise RuntimeError(f"Failed to open {self.device}: {e}")

    def close(self):
        """Close connection to M4F"""
        if self.fd is not None:
            os.close(self.fd)
            self.fd = None

    def send(self, message):
        """Send message to M4F

        Args:
            message: String message to send
        """
        if self.fd is None:
            raise RuntimeError("Not connected. Call connect() first.")

        try:
            data = message.encode('utf-8')
            bytes_written = os.write(self.fd, data)
            print(f"→ Sent: {message} ({bytes_written} bytes)")
            return bytes_written
        except OSError as e:
            raise RuntimeError(f"Failed to send message: {e}")

    def receive(self, timeout=2.0):
        """Receive message from M4F

        Args:
            timeout: Maximum time to wait for response (seconds)

        Returns:
            Received message as string, or None if timeout
        """
        if self.fd is None:
            raise RuntimeError("Not connected. Call connect() first.")

        # Wait for data with timeout
        ready, _, _ = select.select([self.fd], [], [], timeout)

        if not ready:
            return None

        try:
            data = os.read(self.fd, 4096)
            message = data.decode('utf-8', errors='replace')
            print(f"← Received: {message}")
            return message
        except OSError as e:
            raise RuntimeError(f"Failed to receive message: {e}")

    def send_and_receive(self, message, timeout=2.0):
        """Send message and wait for response

        Args:
            message: Message to send
            timeout: Maximum time to wait for response

        Returns:
            Response message or None if timeout
        """
        self.send(message)
        return self.receive(timeout)

    def interactive(self):
        """Interactive mode for communicating with M4F"""
        print("\n=== M4F Interactive Mode ===")
        print("Commands: ping, status, echo <message>, quit")
        print("Type your command and press Enter\n")

        try:
            while True:
                try:
                    cmd = input("M4F> ").strip()

                    if not cmd:
                        continue

                    if cmd.lower() in ('quit', 'exit', 'q'):
                        print("Exiting...")
                        break

                    # Send command and wait for response
                    response = self.send_and_receive(cmd, timeout=2.0)

                    if response is None:
                        print("⚠ No response from M4F (timeout)")

                    print()  # Blank line for readability

                except KeyboardInterrupt:
                    print("\nInterrupted. Type 'quit' to exit.")
                    continue

        except EOFError:
            print("\nExiting...")


def main():
    """Main entry point"""
    parser = argparse.ArgumentParser(
        description="BeaglePlay M4F Client - Communicate with M4F core via RPMsg"
    )
    parser.add_argument(
        'command',
        nargs='?',
        default='interactive',
        help='Command to send (ping, status, echo, interactive)'
    )
    parser.add_argument(
        'args',
        nargs='*',
        help='Additional arguments for command'
    )
    parser.add_argument(
        '-d', '--device',
        help='RPMsg device path (auto-detected if not specified)'
    )
    parser.add_argument(
        '-t', '--timeout',
        type=float,
        default=2.0,
        help='Response timeout in seconds (default: 2.0)'
    )

    args = parser.parse_args()

    try:
        # Create client
        client = M4FClient(device=args.device)
        client.connect()

        # Handle command
        if args.command == 'interactive':
            client.interactive()
        else:
            # Build command string
            if args.args:
                message = f"{args.command} {' '.join(args.args)}"
            else:
                message = args.command

            # Send command and wait for response
            response = client.send_and_receive(message, timeout=args.timeout)

            if response is None:
                print("⚠ No response from M4F (timeout)")
                sys.exit(1)

        # Clean up
        client.close()

    except KeyboardInterrupt:
        print("\nInterrupted")
        sys.exit(130)
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == '__main__':
    main()
