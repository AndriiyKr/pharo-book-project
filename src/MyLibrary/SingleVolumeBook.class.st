Class {
	#name : 'SingleVolumeBook',
	#superclass : 'Book',
	#instVars : [
		'pageCount'
	],
	#category : 'MyLibrary-library',
	#package : 'MyLibrary',
	#tag : 'library'
}

{ #category : 'constants' }
SingleVolumeBook class >> authors: authorCollection title: titleString publishers: publisherCollection year: aYear pageCount: anInteger [
    ^ (self authors: authorCollection title: titleString publishers: publisherCollection year: aYear)
        pageCount: anInteger;
        yourself
]

{ #category : 'constants' }
SingleVolumeBook class >> defaultPageCount [
    ^ 1
]

{ #category : 'arithmetic' }
SingleVolumeBook >> + aNumber [
    self pageCount: self pageCount + aNumber.
    ^ self
]

{ #category : 'arithmetic' }
SingleVolumeBook >> - aNumber [
    self pageCount: ((self pageCount - aNumber) max: self class defaultPageCount).
    ^ self
]

{ #category : 'accessing' }
SingleVolumeBook >> pageCount [
    ^ pageCount ifNil: [ self class defaultPageCount ]
]

{ #category : 'accessing' }
SingleVolumeBook >> pageCount: anInteger [
    anInteger > 0 ifFalse: [ 
        self error: 'Помилка: Кількість сторінок має бути додатним числом!' 
    ].
    pageCount := anInteger
]

{ #category : 'calculations' }
SingleVolumeBook >> totalVolume [
    ^ self pageCount
]
