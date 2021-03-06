testing
testBlockingPeekBufferedPipe

	"(OSPipeTestCase selector: #testBlockingPeekBufferedPipe) run"

	| p |
	p := ExternalPipe bufferedBlockingPipe.
	[p nextPutAll: 'abc'; flush.
	(Delay forMilliseconds: 100) wait. "allow pipe reads to complete"
	self assert: (p peek == $a).
	self assert: (p next == $a).
	self assert: (p peek == $b).
	self assert: (p next == $b).
	self assert: (p peek == $c).
	self deny: p atEnd.
	self assert: (p next == $c).
	self deny: p atEnd.
	p closeWriter.
	self assert: p atEnd]
		ensure: [p close]
