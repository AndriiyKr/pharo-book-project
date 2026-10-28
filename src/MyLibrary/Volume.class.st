"
Том багатотомного видання: номер, назва та кількість сторінок.

Об’єкти з однаковими даними вважаються рівними (=). Томи порівнюються (<) за кількістю сторінок.
Арифметичні оператори + і - змінюють кількість сторінок цього тому і повертають його самого (self).

Instance Variables:
	volumeNumber	<Integer> Номер тому (> 0)
	pageCount		<Integer> Кількість сторінок (> 0)
	titleVolume		<String> Назва тому
"
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
    "Кількість сторінок тому за замовчуванням (і мінімально можлива)"
    ^ 1
]

{ #category : 'constants' }
Volume class >> defaultTitle [
    "Назва тому за замовчуванням, коли назву не задано"
    ^ 'Без назви'
]

{ #category : 'constants' }
Volume class >> defaultVolumeNumber [
    "Номер тому за замовчуванням"
    ^ 1
]

{ #category : 'helpers' }
Volume class >> integerFrom: aValue default: anInteger [
    "Допоміжний метод: nil або порожній рядок дає значення за замовчуванням, рядок з числом
     перетворюється на ціле. Усе інше (зокрема нечисловий рядок) повертається без змін,
     щоб сеттер видав зрозуміле повідомлення про помилку"
    aValue isNil ifTrue: [ ^ anInteger ].
    aValue isString ifFalse: [ ^ aValue ].
    aValue isEmpty ifTrue: [ ^ anInteger ].
    ^ aValue asInteger ifNil: [ aValue ]
]

{ #category : 'instance creation' }
Volume class >> number: anInteger pages: pageInteger title: aString [
    "Створює том із заданими номером, кількістю сторінок і назвою (значення проходять валідацію сеттерів)"
    ^ self new
        volumeNumber: anInteger;
        pageCount: pageInteger;
        titleVolume: aString;
        yourself
]

{ #category : 'instance creation' }
Volume class >> volumeFromDictionary: aDictionary [
    "Створює том зі словника з ключами 'volumeNumber', 'pageCount', 'titleVolume'.
     Відсутні, nil або порожні значення замінюються значеннями за замовчуванням.
     Числа можуть бути рядками (наприклад, прочитаними з файлу). Некоректні значення
     (нуль, від'ємні, нечислові рядки) відхиляються сеттерами з повідомленням про помилку"
    ^ self
        number: (self integerFrom: (aDictionary at: 'volumeNumber' ifAbsent: [ nil ]) default: self defaultVolumeNumber)
        pages: (self integerFrom: (aDictionary at: 'pageCount' ifAbsent: [ nil ]) default: self defaultPageCount)
        title: (aDictionary at: 'titleVolume' ifAbsent: [ nil ])
]

{ #category : 'arithmetic' }
Volume >> + aNumber [
    "Збільшує кількість сторінок цього тому (змінює отримувача) і повертає його самого.
     Результат проходить ту саму валідацію, що й pageCount:, тому при помилці том не змінюється"
    self pageCount: self pageCount + aNumber.
    ^ self
]

{ #category : 'arithmetic' }
Volume >> - aNumber [
    "Зменшує кількість сторінок цього тому (але не нижче defaultPageCount),
     змінює отримувача і повертає його самого"
    self pageCount: ((self pageCount - aNumber) max: self class defaultPageCount).
    ^ self
]

{ #category : 'comparing' }
Volume >> < aVolume [
    "Томи впорядковуються за кількістю сторінок"
    ^ self pageCount < aVolume pageCount
]

{ #category : 'comparing' }
Volume >> = anObject [
    "Томи рівні, якщо збігаються номер, назва та кількість сторінок"
    self == anObject ifTrue: [ ^ true ].
    self class = anObject class ifFalse: [ ^ false ].
    ^ self volumeNumber = anObject volumeNumber
        and: [ self pageCount = anObject pageCount
        and: [ self titleVolume = anObject titleVolume ] ]
]

{ #category : 'comparing' }
Volume >> hash [
    "Узгоджений з =: рівні томи мають однаковий hash"
    ^ (self volumeNumber hash bitXor: self pageCount hash) bitXor: self titleVolume hash
]

{ #category : 'initialization' }
Volume >> initialize [
    "Встановлює значення за замовчуванням, щоб новий том завжди був у коректному стані"
    super initialize.
    volumeNumber := self class defaultVolumeNumber.
    pageCount := self class defaultPageCount.
    titleVolume := self class defaultTitle
]

{ #category : 'accessing' }
Volume >> pageCount [
    "Кількість сторінок тому"
    ^ pageCount
]

{ #category : 'accessing' }
Volume >> pageCount: anInteger [
    "Встановлює кількість сторінок; допускаються лише додатні цілі числа"
    (anInteger isInteger and: [ anInteger > 0 ]) ifFalse: [
        self error: 'Помилка: Кількість сторінок має бути додатним числом!'
    ].
    pageCount := anInteger
]

{ #category : 'printing' }
Volume >> printOn: aStream [
    "Друкує том у вигляді: a Volume (Том N: назва, K стор.)"
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
    "Назва тому"
    ^ titleVolume
]

{ #category : 'accessing' }
Volume >> titleVolume: aString [
    "Встановлює назву; nil або порожній рядок замінюються назвою за замовчуванням"
    titleVolume := (aString ifNil: [ self class defaultTitle ])
        ifEmpty: [ self class defaultTitle ]
]

{ #category : 'accessing' }
Volume >> volumeNumber [
    "Номер тому"
    ^ volumeNumber
]

{ #category : 'accessing' }
Volume >> volumeNumber: anInteger [
    "Встановлює номер тому; допускаються лише додатні цілі числа"
    (anInteger isInteger and: [ anInteger > 0 ]) ifFalse: [
        self error: 'Помилка: Номер тому має бути додатним числом!'
    ].
    volumeNumber := anInteger
]
