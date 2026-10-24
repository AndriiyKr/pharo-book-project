Class {
	#name : 'Monograph',
	#superclass : 'SingleVolumeBook',
	#instVars : [
		'illustrationCount'
	],
	#category : 'MyLibrary-library',
	#package : 'MyLibrary',
	#tag : 'library'
}

{ #category : 'instance creation' }
Monograph class >> authors: authorCollection title: titleString publishers: publisherCollection year: aYear pageCount: anInteger illustrations: illusInteger [
    ^ (self authors: authorCollection title: titleString publishers: publisherCollection year: aYear pageCount: anInteger)
        illustrationCount: illusInteger;
        yourself
]

{ #category : 'constants' }
Monograph class >> defaultIllustrationCount [
    ^ 0
]

{ #category : 'arithmetic' }
Monograph >> + aNumber [
    self illustrationCount: self illustrationCount + aNumber.
    ^ self
]

{ #category : 'arithmetic' }
Monograph >> - aNumber [
    self illustrationCount: ((self illustrationCount - aNumber) max: self class defaultIllustrationCount).
    ^ self
]

{ #category : 'accessing' }
Monograph >> illustrationCount [
    ^ illustrationCount ifNil: [ self class defaultIllustrationCount ]
]

{ #category : 'accessing' }
Monograph >> illustrationCount: anInteger [
    anInteger < 0 ifTrue: [ 
        self error: 'Помилка: Кількість ілюстрацій не може бути від’ємною!' 
    ].
    illustrationCount := anInteger
]

{ #category : 'printing' }
Monograph >> printVolumeInfoOn: aStream [
    aStream 
        nextPutAll: self pageCount; 
        nextPutAll: ' стор. та ';
        nextPutAll: self illustrationCount;
        nextPutAll: ' іл. (загальний обсяг: ';
        nextPutAll: self totalVolume;
        nextPutAll: ' стор., ';
        nextPutAll: self printedSheets; 
        nextPutAll: ' друк. арк.)'
]

{ #category : 'calculations' }
Monograph >> totalVolume [
    ^ super totalVolume + self illustrationCount
]
