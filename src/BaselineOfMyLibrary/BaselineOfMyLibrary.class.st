Class {
	#name : 'BaselineOfMyLibrary',
	#superclass : 'Object',
	#category : 'BaselineOfMyLibrary-library',
	#package : 'BaselineOfMyLibrary',
	#tag : 'library'
}

{ #category : 'baselines' }
BaselineOfMyLibrary >> baseline: spec [
    <baseline>
    spec for: #common do: [ 
        spec package: 'MyLibrary'.
    ]
]
