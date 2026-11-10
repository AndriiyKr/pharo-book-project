"
Цей клас представляє звичайну книгу, що складається з однієї частини та має певну кількість сторінок.

Обсяг (totalVolume) — дорівнює загальній кількості сторінок цієї книги (pageCount).
Встановити або змінити кількість сторінок можна через сетер pageCount:, який строго валідує дані (значення має бути додатним цілим числом).
Оператори + і - відповідно збільшують або зменшують кількість сторінок на задане число та повертають сам об'єкт (self). Оператор віднімання захищений від створення ""від'ємних"" книг — кількість сторінок ніколи не опуститься нижче дефолтного мінімуму.

Instance Variables: 
<pageCount> – кількість сторінок однотомника
"
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

{ #category : 'instance creation' }
SingleVolumeBook class >> authors: authorCollection title: titleString publishers: publisherCollection year: aYear pageCount: anInteger [
    ^ (self authors: authorCollection title: titleString publishers: publisherCollection year: aYear)
        pageCount: anInteger;
        yourself
]

{ #category : 'instance creation' }
SingleVolumeBook class >> bookFromDictionary: aDictionary [
    ^ (super bookFromDictionary: aDictionary)
        pageCount: (aDictionary at: 'pageCount' ifAbsent: [ nil ]);
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

{ #category : 'initialization' }
SingleVolumeBook >> initialize [
    super initialize.
    self pageCount: nil.
]

{ #category : 'accessing' }
SingleVolumeBook >> pageCount [
    ^ pageCount
]

{ #category : 'accessing' }
SingleVolumeBook >> pageCount: aNumber [
    | finalCount |
    finalCount := aNumber ifNil: [ self class defaultPageCount ].
    (finalCount isInteger and: [ finalCount > 0 ]) ifFalse: [
        self error: 'Помилка: Кількість сторінок має бути додатним цілим числом!'
    ].
    pageCount := finalCount
]

{ #category : 'calculations' }
SingleVolumeBook >> totalVolume [
    ^ self pageCount
]
