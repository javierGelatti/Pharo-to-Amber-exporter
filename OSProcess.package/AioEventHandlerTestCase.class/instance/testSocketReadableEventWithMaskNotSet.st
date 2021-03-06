testing
testSocketReadableEventWithMaskNotSet
	"Same as testSocketReadableEvent, except that the mask bit for read events is not set,
	so we expect to not receive the event notification. This is just a check to ensure that
	the event mask is working."

	| port serverName serverTcpSocket clientTcpSocket sema semaIndex socketHandle eventHandler receivedData |
	port := 8086.
	serverName := '127.0.0.1'.
	Socket initializeNetwork.

	"Create the server (reader) socket"
	serverTcpSocket := Socket newTCP.
	serverTcpSocket listenOn: port.

	"Create the client (writer) socket"
	clientTcpSocket := Socket newTCP.
	clientTcpSocket connectTo: (NetNameResolver addressFromString: serverName) port: port.

	"Establish socket connection"
	[serverTcpSocket waitForConnectionFor: 10] fork.
	clientTcpSocket waitForConnectionFor: 10.

	["Set up a read event handler on the server socket"
	sema := Semaphore new.
	semaIndex := Smalltalk registerExternalObject: sema.
	eventHandler := AioEventHandler new.
	socketHandle := eventHandler handleForSocket: serverTcpSocket.

	"An aio handler may already have been established for the socket
	by the SocketPlugin. The following request disables any existing handling
	in order to prevent a warning message on the console stderr."
	eventHandler aioDisable: socketHandle.

	"Now set our own handler."
	[eventHandler
			aioEnable: socketHandle
			forSemaphore: semaIndex
			externalObject: true]
		on: Warning
		do: ["Suppress warning dialog. Unit test will fail next assert."].
	eventHandler
		aioHandle: socketHandle
		exceptionEvents: true
		readEvents: false	"Read event bit not set"
		writeEvents: false.
	self deny: sema isSignaled.
	clientTcpSocket sendData: 'some data to send to the socket'.
	(Delay forMilliseconds: 200) wait.
	self deny: sema isSignaled. "This time we should not receive a signal"
	receivedData := serverTcpSocket receiveAvailableData.
	self assert: 'some data to send to the socket' = receivedData.
	clientTcpSocket close.
	serverTcpSocket close]
		ensure:
			[Smalltalk unregisterExternalObject: sema.
			(socketHandle isKindOf: Integer) ifTrue: [eventHandler aioDisable: socketHandle]]