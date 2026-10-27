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
LibraryTest >> testLargestBook [
	"Перевірка знаходження найбільшої за обсягом книги та її типу"
	| largest |
	largest := library largestBook.
	self assert: largest equals: multivolume.
	self assert: (largest isKindOf: MultivolumeBook).
]

{ #category : 'tests' }
LibraryTest >> testPrintOn [
	"Перевірка текстового представлення об'єкта бібліотеки"
	| stream resultString |
	stream := WriteStream on: String new.
	library printOn: stream.
	resultString := stream contents.
	
	self assert: (resultString includesSubstring: 'Library').
	self assert: (resultString includesSubstring: '5 книг').
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
LibraryTest >> testWithBooks [
	"Перевірка створення бібліотеки через метод класу withBooks:"
	| newLib booksArray |
	booksArray := { singleVolume . monograph }.
	newLib := Library withBooks: booksArray.
	
	self assert: newLib books size equals: 2.
	self assert: (newLib books includes: singleVolume).
	self assert: (newLib books includes: monograph).
]
