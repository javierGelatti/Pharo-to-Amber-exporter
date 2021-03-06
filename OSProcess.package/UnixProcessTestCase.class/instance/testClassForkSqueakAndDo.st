testing - class side methods
testClassForkSqueakAndDo

	"(UnixProcessTestCase selector: #testClassForkSqueakAndDo) run"

	| p openFileCount |
	openFileCount := self numberOfOpenFiles.
	self shouldnt:
			[p := UnixProcess forkSqueakAndDo:
					[(Delay forMilliseconds: 100) wait.
					OSProcess snapshot: false andQuit: true]]
		raise: Warning.
	self assert: p notNil.
	(p == thisOSProcess)
		ifFalse:
			["Parent Squeak process"
			self should: [p isRunning].
			[p isRunning] whileTrue: [(Delay forMilliseconds: 100) wait].
			self should: [p isComplete].
			self should: [p exitStatus == 0].
			self assert: self numberOfOpenFiles == openFileCount]
