#[
    Server
]#

import net, nativesockets, os, threadpool

proc isSocketClosed(sock: Socket): bool =
    try:
        if sock.getSocketError() == 10054.OSErrorCode:
            return true
    except:
        return false

proc recvMsg(sock: Socket) {.thread.} =
    while true:
        if sock.isSocketClosed():
            return
        let cmds: string = sock.recv(1)
        stdout.write cmds

proc sendMsg(sock: Socket) {.thread.} =
    var 
        o: TaintedString
    while true:
        if sock.isSocketClosed():
            return
        
        try:
            o = stdin.readLine()
            sock.send(o & "\r\L")
        except:
            return

when isMainModule:
    let 
        socket = newSocket()
        port = 4444

    socket.bindAddr(Port(port))
    socket.listen()

    var 
        client: Socket
        address = ""
    socket.acceptAddr(client, address)
    echo "Got connection from: " & address

    spawn recvMsg(client)
    spawn sendMsg(client)
    sync()

    echo "Closed"