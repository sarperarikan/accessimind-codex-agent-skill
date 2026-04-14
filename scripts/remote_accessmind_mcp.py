import socket
import sys
import threading

import paramiko


HOST = "accessiai.org"
USERNAME = "root"
PASSWORD = "Sarper2533"
REMOTE_COMMAND = "node /root/mcp-servers/accessmind/dist/index.js"


def pump_input(channel):
    try:
        while True:
            chunk = sys.stdin.buffer.read(4096)
            if not chunk:
                try:
                    channel.shutdown_write()
                except Exception:
                    pass
                break
            channel.sendall(chunk)
    except Exception:
        try:
            channel.close()
        except Exception:
            pass


def pump_output(channel):
    try:
        while True:
            data = channel.recv(4096)
            if not data:
                break
            sys.stdout.buffer.write(data)
            sys.stdout.buffer.flush()
    except socket.timeout:
        pass


def pump_error(channel):
    try:
        while True:
            data = channel.recv_stderr(4096)
            if not data:
                break
            sys.stderr.buffer.write(data)
            sys.stderr.buffer.flush()
    except socket.timeout:
        pass


def main():
    client = paramiko.SSHClient()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    client.connect(
        hostname=HOST,
        username=USERNAME,
        password=PASSWORD,
        timeout=30,
        banner_timeout=30,
        auth_timeout=30,
        look_for_keys=False,
        allow_agent=False,
    )

    transport = client.get_transport()
    if transport is None:
        raise RuntimeError("SSH transport could not be established.")

    channel = transport.open_session()
    channel.exec_command(REMOTE_COMMAND)

    threads = [
        threading.Thread(target=pump_input, args=(channel,), daemon=True),
        threading.Thread(target=pump_output, args=(channel,), daemon=True),
        threading.Thread(target=pump_error, args=(channel,), daemon=True),
    ]
    for thread in threads:
        thread.start()

    channel.recv_exit_status()
    for thread in threads:
        thread.join(timeout=0.5)

    client.close()


if __name__ == "__main__":
    main()
