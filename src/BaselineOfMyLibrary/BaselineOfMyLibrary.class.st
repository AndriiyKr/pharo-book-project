Class {
	#name : 'BaselineOfMyLibrary',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfMyLibrary-library',
	#package : 'BaselineOfMyLibrary',
	#tag : 'library'
}

{ #category : 'baselines' }
BaselineOfMyLibrary >> baseline: spec [
    <baseline>
    spec for: #common do: [ 
        spec package: 'MyLibrary'.
        spec package: 'MyLibrary-Tests' with: [ spec requires: #('MyLibrary') ]
    ]
]

{ #category : 'baselines' }
BaselineOfMyLibrary >> projectClass [
    ^ MetacelloCypressBaselineProject
]
