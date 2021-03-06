pthreads
getThreadID
	"Answer the ID of the pthread that is currently executing (the interpreter thread).
	A thread ID may be a 64 bit value on some platforms, so answer a byte array
	containing the value in machine-dependent byte order."

	"OSProcess accessor getThreadID"

	| osppVer |
	[osppVer := OSProcess accessor osppModuleVersionString asNumber]
		on: Error
		do: [^ nil].
	(osppVer notNil and: [osppVer >= 4.2])
		ifTrue: [^ self primGetThreadID]
		ifFalse: [^ nil]
