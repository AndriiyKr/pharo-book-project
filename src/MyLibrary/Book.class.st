"
Абстрактний базовий клас, що представляє загальну сутність «Книга».

Головною відповідальністю Book є зберігати базові метадані видання та надавати загальний інтерфейс для порівняння книг і розрахунку їхніх друкованих аркушів. Оскільки це абстрактний клас, обчислення загального обсягу делегується конкретним підкласам через абстрактний метод #totalVolume.

Public API and Key Messages:
- totalVolume (абстрактний метод, який мають реалізувати нащадки)
- printedSheets (розраховує кількість друкованих аркушів)
- < та = (дозволяють порівнювати та сортувати книги за їхнім загальним обсягом)
- addAuthor: / addPublisher: (методи для наповнення колекцій авторів та видавництв)

Instance Variables:
	authors		<OrderedCollection of: Author> Колекція об'єктів авторів книги.
	publishers	<OrderedCollection of: Publisher> Колекція об'єктів видавництв, що випустили книгу.
	title		<String> Назва книги.
	year		<Year> Рік видання (об'єкт класу Year).

"
Class {
	#name : 'Book',
	#superclass : 'Magnitude',
	#instVars : [
		'authors',
		'title',
		'publishers',
		'year'
	],
	#category : 'MyLibrary-library',
	#package : 'MyLibrary',
	#tag : 'library'
}

{ #category : 'instance creation' }
Book class >> authors: authorCollection title: titleString publishers: publisherCollection year: yearInteger [
    ^ self new
        authors: authorCollection;
        title: titleString;
        publishers: publisherCollection;
        year: yearInteger;
        yourself
]

{ #category : 'instance creation' }
Book class >> bookFromDictionary: aDictionary [
    ^ self new
        title: ((aDictionary at: 'title' ifAbsent: [ self defaultTitle ]) 
            ifEmpty: [ self defaultTitle ]);
        year: ((aDictionary at: 'year' ifAbsent: [ self defaultYearString ]) 
            ifEmpty: [ self defaultYearString ]);
        authors: ((aDictionary at: 'authors' ifAbsent: [ OrderedCollection new ]) 
            ifEmpty: [ OrderedCollection new ]);
        publishers: ((aDictionary at: 'publishers' ifAbsent: [ OrderedCollection new ]) 
            ifEmpty: [ OrderedCollection new ]);
        yourself
]

{ #category : 'constants' }
Book class >> defaultAuthorName [
    ^ 'Невідомий автор'
]

{ #category : 'constants' }
Book class >> defaultPublisherName [
    ^ 'Невідоме видавництво'
]

{ #category : 'constants' }
Book class >> defaultTitle [
    ^ 'Без назви'
]

{ #category : 'constants' }
Book class >> defaultYearString [
    ^ 'Невідомий рік'
]

{ #category : 'constants' }
Book class >> pagesPerPrintedSheet [
    ^ 32
]

{ #category : 'comparing' }
Book >> < aBook [
	 ^ self totalVolume < aBook totalVolume
]

{ #category : 'comparing' }
Book >> = aBook [
    self == aBook ifTrue: [ ^ true ].
    self class = aBook class ifFalse: [ ^ false ].
    ^ self title = aBook title 
        and: [ self year = aBook year 
        and: [ self authors = aBook authors 
        and: [ self publishers = aBook publishers ] ] ]
]

{ #category : 'initialization' }
Book >> addAuthor: anAuthor [
    authors add: anAuthor
]

{ #category : 'initialization' }
Book >> addPublisher: aPublisher [
    publishers add: aPublisher
]

{ #category : 'initialization' }
Book >> authors [
    ^ authors
]

{ #category : 'initialization' }
Book >> authors: aCollection [
    authors := aCollection
]

{ #category : 'comparing' }
Book >> hash [
    ^ (self title hash bitXor: self year hash) 
        bitXor: (self authors hash bitXor: self publishers hash)
]

{ #category : 'initialization' }
Book >> initialize [
    super initialize.
    authors := OrderedCollection new.
    publishers := OrderedCollection new.
]

{ #category : 'printing' }
Book >> printAuthorsOn: aStream [
    authors isEmpty 
        ifTrue: [ aStream nextPutAll: self class defaultAuthorName ]
        ifFalse: [ 
            authors 
                do: [ :author | aStream nextPutAll: author fullName ]
                separatedBy: [ aStream nextPutAll: ', ' ] ]
]

{ #category : 'printing' }
Book >> printOn: aStream [
    self printTitleOn: aStream.
    aStream nextPutAll: ', '.
    self printAuthorsOn: aStream.
    aStream nextPutAll: ', '.
    self printVolumeInfoOn: aStream.
    aStream nextPutAll: ', '.
    self printYearOn: aStream.
    aStream nextPutAll: ', '.
    self printPublishersOn: aStream
]

{ #category : 'printing' }
Book >> printPublishersOn: aStream [
    publishers isEmpty 
        ifTrue: [ aStream nextPutAll: self class defaultPublisherName ]
        ifFalse: [ 
            publishers 
                do: [ :pub | aStream nextPutAll: pub name ]
                separatedBy: [ aStream nextPutAll: ', ' ] ]
]

{ #category : 'printing' }
Book >> printTitleOn: aStream [
    aStream nextPutAll: (title ifNil: [ self class defaultTitle ])
]

{ #category : 'printing' }
Book >> printVolumeInfoOn: aStream [
    aStream 
        nextPutAll: self totalVolume printString; 
        nextPutAll: ' стор. (';
        nextPutAll: self printedSheets printString; 
        nextPutAll: ' друк. арк.)'
]

{ #category : 'printing' }
Book >> printYearOn: aStream [
    year 
        ifNil: [ aStream nextPutAll: self class defaultYearString ]
        ifNotNil: [ aStream nextPutAll: year year ]
]

{ #category : 'calculations' }
Book >> printedSheets [
	^ (self totalVolume / self class pagesPerPrintedSheet) ceiling
]

{ #category : 'initialization' }
Book >> publishers [
    ^ publishers
]

{ #category : 'initialization' }
Book >> publishers: aCollection [
    publishers := aCollection
]

{ #category : 'initialization' }
Book >> title [
    ^ title
]

{ #category : 'initialization' }
Book >> title: aString [
    title := aString
]

{ #category : 'calculations' }
Book >> totalVolume [
    "Абстрактний метод, бо кожен конкретний тип книги рахує сторінки по-своєму."
    ^ self subclassResponsibility
]

{ #category : 'initialization' }
Book >> year [
    ^ year
]

{ #category : 'initialization' }
Book >> year: aYear [
    (aYear isKindOf: Year) ifFalse: [ 
        self error: 'Помилка: параметр має бути екземпляром Year!' 
    ].
    year := aYear
]
