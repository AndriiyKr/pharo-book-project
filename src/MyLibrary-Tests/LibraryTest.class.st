Class {
	#name : 'LibraryTest',
	#superclass : 'TestCase',
	#instVars : [
		'library',
		'author1',
		'author2',
		'monograph',
		'singleVolume',
		'multivolume',
		'book4',
		'book5'
	],
	#category : 'MyLibrary-Tests',
	#package : 'MyLibrary-Tests'
}

{ #category : 'running' }
LibraryTest >> setUp [
	"Налаштування контексту тестів"
	super setUp.
	library := Library new.
	
	author1 := Author new firstName: 'Іван'; lastName: 'Франко'.
	author2 := Author new firstName: 'Леся'; lastName: 'Українка'.
	
	singleVolume := SingleVolumeBook new title: 'Зів''яле листя'; addAuthor: author1; pageCount: 100.
	monograph := Monograph new title: 'Історія української літератури'; addAuthor: author1; pageCount: 200; illustrationCount: 50.
	
	multivolume := MultivolumeBook new title: 'Зібрання творів'; addAuthor: author2.
	multivolume + (Volume new volumeNumber: 1; pageCount: 300).
	multivolume + (Volume new volumeNumber: 2; pageCount: 400).
	
	book4 := SingleVolumeBook new title: 'Лісова пісня'; addAuthor: author2; pageCount: 150.
	book5 := SingleVolumeBook new title: 'Захар Беркут'; addAuthor: author1; pageCount: 250.
	
	library addBook: singleVolume.
	library addBook: monograph.
	library addBook: multivolume.
	library addBook: book4.
	library addBook: book5.
]

{ #category : 'tests' }
LibraryTest >> testAddBook [
	"Перевірка додавання книги до бібліотеки та відхилення неправильних об'єктів"
	| newLib |
	newLib := Library new.
	self assert: newLib books size equals: 0.
	newLib addBook: singleVolume.
	self assert: newLib books size equals: 1.
	self should: [ newLib addBook: 'Якийсь рядок' ] raise: Error.
]

{ #category : 'tests' }
LibraryTest >> testAddBooks [
	"Перевірка пакетного додавання масиву книг"
	| newLib booksArray |
	newLib := Library new.
	self assert: newLib books size equals: 0.
	
	booksArray := { singleVolume . monograph . multivolume }.
	newLib addBooks: booksArray.
	
	self assert: newLib books size equals: 3.
	self assert: (newLib books includes: singleVolume).
	self assert: (newLib books includes: monograph).
	self assert: (newLib books includes: multivolume).
]

{ #category : 'tests' }
LibraryTest >> testBooksByAuthor [
	"Перевірка створення колекції книг для конкретного автора"
	| frankoBooks lesyaBooks |
	frankoBooks := library booksByAuthor: author1.
	self assert: frankoBooks size equals: 3.
	self assert: (frankoBooks includes: singleVolume).
	self assert: (frankoBooks includes: monograph).
	self assert: (frankoBooks includes: book5).
	
	lesyaBooks := library booksByAuthor: author2.
	self assert: lesyaBooks size equals: 2.
	self assert: (lesyaBooks includes: multivolume).
	self assert: (lesyaBooks includes: book4).
]

{ #category : 'tests' }
LibraryTest >> testBooksByPublisher [
    | lib book pub1 pub2 |
    lib := Library new.
    pub1 := Publisher new name: 'Основи'.
    pub2 := Publisher new name: 'Фоліо'.
    
    book := SingleVolumeBook new title: 'Тест'.
    book addPublisher: pub1.
    lib addBook: book.
    
    self assert: (lib booksByPublisher: pub1) size equals: 1.
    self assert: (lib booksByPublisher: pub2) isEmpty.
]

{ #category : 'tests' }
LibraryTest >> testBooksByYear [
    | lib book year2020 year2024 |
    lib := Library new.
    year2020 := Year year: 2020.
    year2024 := Year year: 2024.
    
    book := SingleVolumeBook new title: 'Тест'; year: year2020.
    lib addBook: book.
    
    self assert: (lib booksByYear: year2020) size equals: 1.
    self assert: (lib booksByYear: year2024) isEmpty.
]

{ #category : 'tests' }
LibraryTest >> testLargestBook [
	"Перевірка знаходження найбільшої за обсягом книги та її типу"
	| largest |
	largest := library largestBook.
	self assert: largest equals: multivolume.
	self assert: (largest isKindOf: MultivolumeBook).
]

{ #category : 'tests' }
LibraryTest >> testName [
    | lib |
    lib := Library new.
    
    "Перевірка дефолтного значення при створенні"
    self assert: lib name equals: Library defaultName.
    
    "Звичайне встановлення"
    lib name: 'Центральна міська бібліотека'.
    self assert: lib name equals: 'Центральна міська бібліотека'.
    
    "Перевірка реакції на nil"
    lib name: nil.
    self assert: lib name equals: Library defaultName.
    
    "Перевірка реакції на порожній рядок"
    lib name: ''.
    self assert: lib name equals: Library defaultName.
]

{ #category : 'tests' }
LibraryTest >> testPrintBooksByYearOn [
    | lib book printString year2024 |
    lib := Library new.
    year2024 := Year year: 2024.
    book := SingleVolumeBook new title: 'Тестова книга'; year: year2024.
    lib addBook: book.

    printString := String streamContents: [ :stream | 
        lib printBooksByYear: year2024 on: stream 
    ].
    
    self assert: (printString includesSubstring: '--- Книги 2024 року (1 шт.) ---').
    self assert: (printString includesSubstring: 'Тестова книга').
]

{ #category : 'tests' }
LibraryTest >> testPrintOn [
    | lib printString |
    lib := Library new.
    lib name: 'Тестова бібліотека'.
    printString := String streamContents: [ :stream | lib printOn: stream ].
    self assert: (printString includesSubstring: 'a Library "Тестова бібліотека" (0 примірників)').
]

{ #category : 'tests' }
LibraryTest >> testRemoveBook [
	"Перевіряє успішне видалення книги та обробку помилки для неіснуючого об'єкта"
	| initialSize dummyBook |
	initialSize := library books size.
	
	"Успішне видалення існуючої книги (singleVolume додається у setUp)"
	library removeBook: singleVolume.
	self assert: library books size equals: initialSize - 1.
	self deny: (library books includes: singleVolume).
	
	"Перевірка помилки при спробі видалити книгу, якої немає"
	dummyBook := SingleVolumeBook new title: 'Неіснуюча книга'; yourself.
	self should: [ library removeBook: dummyBook ] raise: Error.
]

{ #category : 'tests' }
LibraryTest >> testReplaceBook [
    | lib oldBook newBook |
    lib := Library new.
    oldBook := SingleVolumeBook new title: 'Стара версія'; year: (Year year: 2000).
    newBook := SingleVolumeBook new title: 'Нова версія'; year: (Year year: 2024).
    
    "Додаємо 2 копії старої книги"
    lib addBook: oldBook; addBook: oldBook.
    
    "Замінюємо стару на нову"
    lib replaceBook: oldBook with: newBook.
    
    "Перевіряємо, що старих не залишилося, а нових з'явилося рівно стільки ж (2)"
    self assert: (lib copiesOf: oldBook) equals: 0.
    self assert: (lib copiesOf: newBook) equals: 2.
    self assert: lib totalCopies equals: 2.
    
    "Перевірка помилки при спробі замінити неіснуючу книгу"
    self should: [ lib replaceBook: oldBook with: newBook ] raise: Error.
]

{ #category : 'tests' }
LibraryTest >> testSTONSerialization [
	"Перевіряє, чи коректно бібліотека зберігається та відновлюється зі STON"
	| fileName testFile loadedLibrary |
	
	fileName := 'test_library.ston'.
	testFile := fileName asFileReference.
	
	"Зберігаємо фікстуру (library з setUp, де вже є 5 книг)"
	library saveToSTON: fileName.
	
	"Створюємо нову бібліотеку і завантажуємо"
	loadedLibrary := Library new.
	loadedLibrary loadFromSTON: fileName.
	
	"Робимо перевірки"
	self assert: loadedLibrary books size equals: library books size.
	self assert: loadedLibrary books first title equals: library books first title.
	
	"Видаляємо тестовий файл, щоб не засмічувати диск"
	testFile ensureDelete.
]

{ #category : 'tests' }
LibraryTest >> testTotalCopiesAndCopiesOf [
    | lib book1 book2 |
    lib := Library new.
    book1 := SingleVolumeBook new title: 'Кобзар'; pageCount: 100.
    book2 := SingleVolumeBook new title: 'Енеїда'; pageCount: 200.
    
    "Додаємо 2 копії першої книги і 1 копію другої"
    lib addBook: book1; addBook: book1; addBook: book2.
    
    self assert: lib totalCopies equals: 3.
    self assert: (lib copiesOf: book1) equals: 2.
    self assert: (lib copiesOf: book2) equals: 1.
    self assert: (lib copiesOf: (SingleVolumeBook new title: 'Неіснуюча')) equals: 0.
]

{ #category : 'tests' }
LibraryTest >> testTotalPrintedSheets [
    | lib book1 book2 |
    lib := Library new.
    "Перевірка для порожньої бібліотеки"
    self assert: lib totalPrintedSheets equals: 0.
    
    "Створюємо книги з відомою кількістю сторінок"
    book1 := SingleVolumeBook new pageCount: 16. 
    book2 := SingleVolumeBook new pageCount: 32. 
    
    lib addBook: book1; addBook: book2.
    
    "Загальна кількість має дорівнювати сумі"
    self assert: lib totalPrintedSheets equals: 2.
]

{ #category : 'tests' }
LibraryTest >> testWithBooks [
	"Перевірка створення бібліотеки через метод класу withBooks:"
	| newLib booksArray |
	booksArray := { singleVolume . monograph }.
	newLib := Library withBooks: booksArray.
	
	self assert: newLib books size equals: 2.
	self assert: (newLib books includes: singleVolume).
	self assert: (newLib books includes: monograph).
]
