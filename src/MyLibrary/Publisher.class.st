"
Цей клас представляє сутність «Видавництво».

Головна відповідальність Publisher зберігати інформацію про організацію, яка видала книгу (назва, місто та рік заснування). Базовий клас Book містить колекцію екземплярів класу Publisher, щоб підтримувати спільні проєкти.

Public API and Key Messages:
- name:city:foundationYear: (конструктор класу)
- defaultPublisher (повертає видавництво за замовчуванням)

Instance Variables:
	city			<String> Місто, де розташоване видавництво.
	foundationYear	<Year> Рік заснування видавництва.
	name			<String> Назва видавництва.
"
Class {
	#name : 'Publisher',
	#superclass : 'Object',
	#instVars : [
		'name',
		'city',
		'foundationYear'
	],
	#category : 'MyLibrary-library',
	#package : 'MyLibrary',
	#tag : 'library'
}

{ #category : 'constants' }
Publisher class >> defaultCity [
    ^ 'Невідоме місто'
]

{ #category : 'constants' }
Publisher class >> defaultFoundationYear [
    ^ Year current
]

{ #category : 'constants' }
Publisher class >> defaultName [
    ^ 'Невідоме видавництво'
]

{ #category : 'constants' }
Publisher class >> defaultPublisher [
    ^ self 
        name: self defaultName 
        city: self defaultCity 
        foundationYear: self defaultFoundationYear.
]

{ #category : 'instance creation' }
Publisher class >> name: aName city: aCity foundationYear: aYear [
    ^ self new
        name: aName;
        city: aCity;
        foundationYear: aYear;
        yourself
]

{ #category : 'constants' }
Publisher class >> publisherFromDictionary: aDictionary [
    ^ self new
        name: (aDictionary at: 'name' ifAbsent: [ nil ]);
        city: (aDictionary at: 'city' ifAbsent: [ nil ]);
        foundationYear: (aDictionary at: 'foundationYear' ifAbsent: [ nil ]);
        yourself
]

{ #category : 'accessing' }
Publisher >> city [
    ^ city
]

{ #category : 'accessing' }
Publisher >> city: aString [
    city := (aString ifNil: [ self class defaultCity ]) 
        ifEmpty: [ self class defaultCity ]
]

{ #category : 'accessing' }
Publisher >> foundationYear [
    ^ foundationYear
]

{ #category : 'accessing' }
Publisher >> foundationYear: aYear [
    | finalYear |
    finalYear := aYear ifNil: [ self class defaultFoundationYear ].
    (finalYear isKindOf: Year) ifFalse: [ 
        self error: 'Помилка: foundationYear має бути екземпляром Year!' 
    ].
    foundationYear := finalYear
]

{ #category : 'accessing' }
Publisher >> name [
    ^ name
]

{ #category : 'accessing' }
Publisher >> name: aString [
    name := (aString ifNil: [ self class defaultName ]) 
        ifEmpty: [ self class defaultName ]
]

{ #category : 'printing' }
Publisher >> printOn: aStream [
    super printOn: aStream.
    aStream nextPutAll: ' ('.
    aStream nextPutAll: (name ifNil: [ self class defaultName ]).
    aStream nextPutAll: ', м. '.
    aStream nextPutAll: (city ifNil: [ self class defaultCity ]).
    aStream nextPut: $)
]
