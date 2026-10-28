"
Я представляю бібліотеку, яка є контейнером для зберігання колекції книг.

Моя головна відповідальність — керувати колекцією книг та надавати зручні інструменти для роботи з ними. Я знаю всі додані до мене книги та можу виконувати запити, наприклад, пошук найбільшого видання за обсягом. Також я вмію взаємодіяти з користувачем через графічні діалоги для покрокового створення та додавання нових об'єктів книг.

Мої головні колаборатори:
- Book (та її нащадки SingleVolumeBook, MultivolumeBook, Monograph): я зберігаю їх у своїй колекції та делегую їм запити щодо обсягу чи авторів.
- Author: я використовую екземпляри авторів як критерій для фільтрації мого списку книг.
- UIManager: взаємодію з ним для виведення діалогових вікон під час ручного додавання книги.

Публічний API та ключові повідомлення:
- addBook: aBook (додає нову книгу до колекції, перевіряючи, чи є вона екземпляром Book).
- largestBook (повертає книгу з найбільшим загальним обсягом).
- booksByAuthor: anAuthor (повертає нову колекцію, що містить книги заданого автора).
- addBookViaDialog (відкриває системні вікна для введення даних та автоматично формує об'єкт книги).
- Створення екземпляра: Library new.

Один простий приклад:
| lib author book |
lib := Library new.
author := Author new firstName: 'Тарас'; lastName: 'Шевченко'.
book := SingleVolumeBook new title: 'Кобзар'; addAuthor: author; pageCount: 600.
lib addBook: book.
lib largestBook.

Внутрішнє представлення та ключові деталі реалізації:
- Змінні екземпляра: books <OrderedCollection>.
- Деталі реалізації: Книги зберігаються в OrderedCollection. Для визначення найбільшої книги метод #largestBook використовує перебір #inject:into: замість стандартного сортування чи максимуму колекції. Це архітектурне рішення захищає від потенційних помилок сортування (MessageNotUnderstood), оскільки у базовому класі Book не повністю реалізовано протокол Magnitude.
"
Class {
	#name : 'Library',
	#superclass : 'Object',
	#instVars : [
		'books'
	],
	#category : 'MyLibrary-container',
	#package : 'MyLibrary',
	#tag : 'container'
}

{ #category : 'instance creation' }
Library class >> withBooks: aCollectionOfBooks [
	"Створює екземпляр бібліотеки та ініціалізує його переданою колекцією книг"
	^ self new
		addBooks: aCollectionOfBooks;
		yourself
]

{ #category : 'adding' }
Library >> addBook: aBook [
	"Додає книгу до бібліотеки"
	(aBook isKindOf: Book) ifFalse: [
		self error: 'До бібліотеки можна додавати лише екземпляри класу Book або його нащадків!'
	].
	books add: aBook
]

{ #category : 'ui-dialogs' }
Library >> addBookViaDialog [
	"Інтерфейс діалогу з користувачем для створення книг різних типів із підтримкою декількох авторів"
	| choices bookType titleStr yearStr pubName newBook newPublisher pagesStr illusStr volCountStr volPagesStr authorsList addMore authorFirst authorLast |
	
	choices := { 'Однотомник' . 'Монографія' . 'Багатотомник' }.
	bookType := UIManager default chooseFrom: choices title: 'Оберіть тип книги:'.
	bookType = 0 ifTrue: [ ^ self ].
	
	titleStr := UIManager default request: 'Введіть назву книги:' initialAnswer: 'Нова книга'.
	titleStr ifNil: [ ^ self ].
	
	yearStr := UIManager default request: 'Введіть рік видання:' initialAnswer: '2023'.
	yearStr ifNil: [ ^ self ].
	
	authorsList := OrderedCollection new.
	addMore := true.
	[ addMore ] whileTrue: [
		authorFirst := UIManager default request: 'Введіть ім''я автора:' initialAnswer: 'Тарас'.
		authorFirst ifNotNil: [
			authorLast := UIManager default request: 'Введіть прізвище автора:' initialAnswer: 'Шевченко'.
			authorLast ifNotNil: [
				authorsList add: (Author new firstName: authorFirst; lastName: authorLast).
				addMore := UIManager default confirm: 'Бажаєте додати ще одного автора?'.
			] ifNil: [ addMore := false ]
		] ifNil: [ addMore := false ]
	].
	authorsList ifEmpty: [ ^ self ]. "Припиняємо створення, якщо не додано жодного автора"
	
	pubName := UIManager default request: 'Введіть назву видавництва:' initialAnswer: 'А-БА-БА-ГА-ЛА-МА-ГА'.
	pubName ifNil: [ ^ self ].
	newPublisher := Publisher new name: pubName.
	
	bookType = 1 ifTrue: [
		pagesStr := UIManager default request: 'Введіть кількість сторінок:' initialAnswer: '100'.
		pagesStr ifNil: [ ^ self ].
		newBook := SingleVolumeBook new pageCount: pagesStr asInteger.
	].
	
	bookType = 2 ifTrue: [
		pagesStr := UIManager default request: 'Введіть кількість сторінок:' initialAnswer: '200'.
		pagesStr ifNil: [ ^ self ].
		illusStr := UIManager default request: 'Введіть кількість ілюстрацій:' initialAnswer: '10'.
		illusStr ifNil: [ ^ self ].
		newBook := Monograph new pageCount: pagesStr asInteger; illustrationCount: illusStr asInteger.
	].
	
	bookType = 3 ifTrue: [
		newBook := MultivolumeBook new.
		volCountStr := UIManager default request: 'Введіть кількість томів:' initialAnswer: '2'.
		volCountStr ifNil: [ ^ self ].
		1 to: volCountStr asInteger do: [ :i |
			volPagesStr := UIManager default request: ('Введіть кількість сторінок для тому ', i asString, ':') initialAnswer: '300'.
			volPagesStr ifNil: [ ^ self ].
			newBook + (Volume new volumeNumber: i; pageCount: volPagesStr asInteger).
		].
	].
	
	newBook title: titleStr; year: (Year year: yearStr asInteger); addPublisher: newPublisher.
	authorsList do: [ :eachAuthor | newBook addAuthor: eachAuthor ].
	
	self addBook: newBook.
	UIManager default inform: 'Книгу "', titleStr, '" успішно додано до бібліотеки!'
]

{ #category : 'adding' }
Library >> addBooks: aCollectionOfBooks [
	"Додає колекцію (або масив) книг до бібліотеки"
	aCollectionOfBooks do: [ :each | self addBook: each ]
]

{ #category : 'accessing' }
Library >> books [
	^ books
]

{ #category : 'queries' }
Library >> booksByAuthor: anAuthor [
	"Створює нову колекцію, що містить книги певного автора"
	^ books select: [ :eachBook | eachBook authors includes: anAuthor ]
]

{ #category : 'file-io' }
Library >> exportToText: aFileName [
    "Зберігає текстове представлення бібліотеки у файл"
    aFileName asFileReference writeStreamDo: [ :stream |
        self printAllBooksOn: stream
    ]
]

{ #category : 'initialization' }
Library >> initialize [
	super initialize.
	books := OrderedCollection new.
]

{ #category : 'queries' }
Library >> largestBook [
	"Повертає книгу з найбільшим загальним обсягом (totalVolume)"
	books ifEmpty: [ ^ nil ].
	
	^ books inject: books first into: [ :maxBook :eachBook |
		eachBook totalVolume > maxBook totalVolume
			ifTrue: [ eachBook ]
			ifFalse: [ maxBook ]
	]
]

{ #category : 'file-io' }
Library >> loadFromSTON: aFileName [
    "Десеріалізує об'єкти потрібних класів"
    aFileName asFileReference readStreamDo: [ :stream |
        books := STON fromStream: stream.
    ]
]

{ #category : 'printing' }
Library >> printAllBooks [
	"Зручний метод для виводу в Transcript"
	self printAllBooksOn: Transcript
]

{ #category : 'printing' }
Library >> printAllBooksOn: aStream [
	"Друкує всі елементи контейнера"
	books do: [ :each |
		each printOn: aStream.
		aStream cr.
	]
]

{ #category : 'printing' }
Library >> printOn: aStream [
	super printOn: aStream.
	aStream nextPutAll: ' ('.
	aStream nextPutAll: books size printString.
	aStream nextPutAll: ' книг)'
]

{ #category : 'adding/removing' }
Library >> removeBook: aBook [
	"Видаляє книгу з контейнера. Якщо її немає, то генерує помилку."
	books remove: aBook ifAbsent: [ self error: 'Книгу не знайдено у бібліотеці' ]
]

{ #category : 'file-io' }
Library >> saveToSTON: aFileName [
    "Серіалізує всі об'єкти"
    aFileName asFileReference writeStreamDo: [ :stream |
        STON put: books onStreamPretty: stream.
    ]
]
