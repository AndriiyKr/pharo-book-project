"
Цей клас представляє сутність «Автор».

Головною відповідальністю класу Author є зберігати особисті дані письменника (ім'я, прізвище, дату народження та місто проживання). Базовий клас Book використовує екземпляри класу у своїй колекції authors для формування правильного списку творців.

Public API and Key Messages:
- fullName (генерує повне ім'я у вигляді рядка)
- firstName:lastName:birthDate:city: (конструктор класу)
- defaultAuthor (повертає автора за замовчуванням)

Instance Variables:
	birthDate	<Date> Дата народження автора.
	city		<String> Місто проживання.
	firstName	<String> Ім'я.
	lastName	<String> Прізвище.
"
Class {
	#name : 'Author',
	#superclass : 'Object',
	#instVars : [
		'firstName',
		'lastName',
		'birthDate',
		'city'
	],
	#category : 'MyLibrary-library',
	#package : 'MyLibrary',
	#tag : 'library'
}

{ #category : 'constants' }
Author class >> defaultAuthor [
    ^ self 
        firstName: self defaultFirstName 
        lastName: self defaultLastName 
        birthDate: Date today 
        city: 'Невідоме місто'
]

{ #category : 'constants' }
Author class >> defaultFirstName [
    ^ 'Невідомий'
]

{ #category : 'constants' }
Author class >> defaultLastName [
    ^ 'Автор'
]

{ #category : 'accessing' }
Author class >> firstName: aFirstName lastName: aLastName birthDate: aDate city: aCity [
    ^ self new
        firstName: aFirstName;
        lastName: aLastName;
        birthDate: aDate;
        city: aCity;
        yourself
]

{ #category : 'accessing' }
Author >> birthDate [
    ^ birthDate
]

{ #category : 'accessing' }
Author >> birthDate: aDate [
    (aDate isKindOf: Date) ifFalse: [ 
        self error: 'Помилка: birthDate має бути екземпляром Date!' 
    ].
    birthDate := aDate
]

{ #category : 'accessing' }
Author >> city [
    ^ city
]

{ #category : 'accessing' }
Author >> city: aString [
    city := aString
]

{ #category : 'accessing' }
Author >> firstName [
    ^ firstName
]

{ #category : 'accessing' }
Author >> firstName: aString [
    firstName := aString
]

{ #category : 'accessing' }
Author >> fullName [
    "Повертає повне ім'я автора"
    ^ (firstName ifNil: [ self class defaultFirstName ]), ' ', (lastName ifNil: [ self class defaultLastName ])
]

{ #category : 'accessing' }
Author >> lastName [
    ^ lastName
]

{ #category : 'accessing' }
Author >> lastName: aString [
    lastName := aString
]

{ #category : 'printing' }
Author >> printOn: aStream [
    super printOn: aStream.
    aStream nextPutAll: ' ('; nextPutAll: self fullName; nextPutAll: ')'
]
