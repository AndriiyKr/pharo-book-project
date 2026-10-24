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
	#category : 'MyLibrary-library',
	#package : 'MyLibrary',
	#tag : 'library'
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
	"Інтерфейс діалогу з користувачем для створення простої однотомної книги"
	| titleStr yearStr pagesStr newBook |
	
	titleStr := UIManager default request: 'Введіть назву книги:' initialAnswer: 'Нова книга'.
	titleStr ifNil: [ ^ self ].
	
	yearStr := UIManager default request: 'Введіть рік видання:' initialAnswer: '2023'.
	yearStr ifNil: [ ^ self ].
	
	pagesStr := UIManager default request: 'Введіть кількість сторінок:' initialAnswer: '100'.
	pagesStr ifNil: [ ^ self ].
	
	newBook := SingleVolumeBook new
		title: titleStr;
		year: (Year year: yearStr asInteger);
		pageCount: pagesStr asInteger;
		yourself.
		
	self addBook: newBook.
	UIManager default inform: 'Книгу "', titleStr, '" успішно додано до бібліотеки!'.
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
