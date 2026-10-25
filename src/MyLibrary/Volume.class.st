Class {
	#name : 'Volume',
	#superclass : 'Object',
	#instVars : [
		'volumeNumber',
		'pageCount',
		'titleVolume'
	],
	#category : 'MyLibrary-library',
	#package : 'MyLibrary',
	#tag : 'library'
}

{ #category : 'constants' }
Volume class >> defaultPageCount [
    ^ 1
]

{ #category : 'constants' }
Volume class >> defaultTitle [
    ^ 'Без назви'
]

{ #category : 'constants' }
Volume class >> defaultVolumeNumber [
    ^ 1
]

{ #category : 'instance creation' }
Volume class >> number: anInteger pages: pageInteger title: aString [
    ^ self new
        volumeNumber: anInteger;
        pageCount: pageInteger;
        titleVolume: aString;
        yourself
]

{ #category : 'arithmetic' }
Volume >> + aNumber [
    pageCount := self pageCount + aNumber.
    ^ self
]

{ #category : 'arithmetic' }
Volume >> - aNumber [
    self pageCount: ((self pageCount - aNumber) max: self class defaultPageCount).
    ^ self
]

{ #category : 'accessing' }
Volume >> pageCount [
    ^ pageCount ifNil: [ self class defaultPageCount ]
]

{ #category : 'accessing' }
Volume >> pageCount: anInteger [
    anInteger > 0 ifFalse: [ 
        self error: 'Помилка: Кількість сторінок має бути додатним числом!' 
    ].
    pageCount := anInteger
]

{ #category : 'printing' }
Volume >> printOn: aStream [
    super printOn: aStream.
    aStream 
        nextPutAll: ' (Том ';
        nextPutAll: self volumeNumber printString;
        nextPutAll: ': ';
        nextPutAll: self titleVolume;
        nextPutAll: ', ';
        nextPutAll: self pageCount printString;
        nextPutAll: ' стор.)'
]

{ #category : 'accessing' }
Volume >> titleVolume [
    ^ titleVolume ifNil: [ self class defaultTitle ]
]

{ #category : 'accessing' }
Volume >> titleVolume: aString [
    titleVolume := aString
]

{ #category : 'accessing' }
Volume >> volumeNumber [
    ^ volumeNumber ifNil: [ self class defaultVolumeNumber ]
]

{ #category : 'accessing' }
Volume >> volumeNumber: anInteger [
    anInteger > 0 ifFalse: [ 
        self error: 'Помилка: Номер тому має бути додатним числом!' 
    ].
    volumeNumber := anInteger
]
