"
Багатотомне видання: книга, що складається з томів (екземплярів Volume).

Обсяг (totalVolume) — сума сторінок усіх томів. Номери томів унікальні в межах багатотомника.
Змінити склад томів можна через addVolume: / removeVolume: / volumes:.
Оператори + і - додають і видаляють том у цьому багатотомнику (через addVolume: / removeVolume:)
і повертають його самого (self).
Геттер volumes повертає копію колекції, тому обійти валідацію через volumes add: неможливо.

Instance Variables:
	volumes	<OrderedCollection of: Volume> Томи багатотомника
"
Class {
	#name : 'MultivolumeBook',
	#superclass : 'Book',
	#instVars : [
		'volumes'
	],
	#category : 'MyLibrary-library',
	#package : 'MyLibrary',
	#tag : 'library'
}

{ #category : 'instance creation' }
MultivolumeBook class >> authors: authorCollection title: titleString publishers: publisherCollection year: aYear volumes: volumeCollection [
    "Створює багатотомник з метаданими Book і колекцією томів"
    ^ (self authors: authorCollection title: titleString publishers: publisherCollection year: aYear)
        volumes: volumeCollection;
        yourself
]

{ #category : 'instance creation' }
MultivolumeBook class >> bookFromDictionary: aDictionary [
    "Створює багатотомник зі словника з ключами 'title', 'year', 'authors', 'publishers', 'volumes'.
     Рік - Year, ціле число або рядок з числом; відсутній чи порожній рік дає рік за замовчуванням.
     Відсутні назва, автори чи видавництва замінюються значеннями за замовчуванням (це робить Book).
     Томи - колекція екземплярів Volume або словників (див. Volume class >> volumeFromDictionary:).
     Метод не викликає Book class >> bookFromDictionary:, бо той передає рік як є,
     а Book >> year: приймає лише Year (або nil)"
    | book rawYear |
    book := self new.
    book title: (aDictionary at: 'title' ifAbsent: [ nil ]).
    rawYear := aDictionary at: 'year' ifAbsent: [ nil ].
    book year: ((rawYear isNil or: [ rawYear isString and: [ rawYear isEmpty ] ])
        ifTrue: [ nil ]
        ifFalse: [ self yearFrom: rawYear ]).
    book authors: (OrderedCollection withAll: ((aDictionary at: 'authors' ifAbsent: [ nil ]) ifNil: [ #() ])).
    book publishers: (OrderedCollection withAll: ((aDictionary at: 'publishers' ifAbsent: [ nil ]) ifNil: [ #() ])).
    book volumes: (((aDictionary at: 'volumes' ifAbsent: [ nil ]) ifNil: [ #() ])
        collect: [ :each | self volumeFrom: each ]).
    ^ book
]

{ #category : 'helpers' }
MultivolumeBook class >> volumeFrom: anObject [
    "Допоміжний метод: том може бути екземпляром Volume або словником для Volume "
    (anObject isKindOf: Volume) ifTrue: [ ^ anObject ].
    (anObject isKindOf: Dictionary) ifTrue: [ ^ Volume volumeFromDictionary: anObject ].
    ^ self error: 'Помилка: Том має бути екземпляром класу Volume або словником!'
]

{ #category : 'helpers' }
MultivolumeBook class >> yearFrom: aValue [
    "Допоміжний метод: перетворює Year, ціле число або рядок з числом на екземпляр Year"
    (aValue isKindOf: Year) ifTrue: [ ^ aValue ].
    aValue isInteger ifTrue: [ ^ Year year: aValue ].
    (aValue isString and: [ aValue asInteger notNil ]) ifTrue: [ ^ Year year: aValue asInteger ].
    ^ self error: 'Помилка: Неможливо перетворити значення на рік: ', aValue printString
]

{ #category : 'arithmetic' }
MultivolumeBook >> + aVolume [
    "Додає том у цей багатотомник (змінює отримувача) і повертає його самого,
     тому оператори можна ланцюжити. Валідація та унікальність номерів - в addVolume:"
    self addVolume: aVolume.
    ^ self
]

{ #category : 'arithmetic' }
MultivolumeBook >> - aVolume [
    "Видаляє том із цього багатотомника (змінює отримувача) і повертає його самого.
     Якщо такого тому немає, виникає помилка (див. removeVolume:)"
    self removeVolume: aVolume.
    ^ self
]

{ #category : 'comparing' }
MultivolumeBook >> = anObject [
    "До порівняння метаданих Book (назва, рік, автори, видавництва) додається порівняння томів.
     hash навмисно НЕ змінюється: рівні об'єкти мають рівні hash, а hash не залежить від
     змінної колекції томів (інакше додавання тому «ламало» б багатотомник у Set/Dictionary)"
    ^ super = anObject and: [ self volumes = anObject volumes ]
]

{ #category : 'adding' }
MultivolumeBook >> addVolume: aVolume [
    "Додає том у багатотомник (змінює отримувача). Повертає доданий том.
     Номери томів у межах багатотомника мають бути унікальними"
    (aVolume isKindOf: Volume) ifFalse: [
        self error: 'Помилка: До багатотомника можна додавати лише об’єкти класу Volume!'
    ].
    (self hasVolumeNumbered: aVolume volumeNumber) ifTrue: [
        self error: 'Помилка: Том з таким номером уже є в багатотомнику!'
    ].
    ^ volumes add: aVolume
]

{ #category : 'testing' }
MultivolumeBook >> hasVolumeNumbered: anInteger [
    "Чи є в багатотомнику том із заданим номером"
    ^ volumes anySatisfy: [ :each | each volumeNumber = anInteger ]
]

{ #category : 'initialization' }
MultivolumeBook >> initialize [
    "Створює порожню колекцію томів (після ініціалізації полів Book)"
    super initialize.
    volumes := OrderedCollection new.
    self title: nil.
    self authors: nil.
    self publishers: nil.
    self year: nil
]

{ #category : 'copying' }
MultivolumeBook >> postCopy [
    "Копія отримує власні колекції томів, авторів і видавництв (і власні копії томів),
     а не ділить їх з оригіналом. Авторів і видавництва копіюємо через сеттери Book.
     Тип колекції зберігається (copy), щоб копія залишалася рівною оригіналу за Book >> ="
    super postCopy.
    volumes := volumes collect: [ :each | each copy ].
    self authors: self authors copy.
    self publishers: self publishers copy
]

{ #category : 'printing' }
MultivolumeBook >> printVolumeInfoOn: aStream [
    "Друкує інформацію про обсяг у вигляді: N томів (загалом K стор., S друк. арк.)"
    aStream
        nextPutAll: self volumeCount printString;
        nextPutAll: ' томів (загалом ';
        nextPutAll: self totalVolume printString;
        nextPutAll: ' стор., ';
        nextPutAll: self printedSheets printString;
        nextPutAll: ' друк. арк.)'
]

{ #category : 'removing' }
MultivolumeBook >> removeVolume: aVolume [
    "Видаляє том (змінює отримувача). Томи порівнюються за значенням (Volume >> =)"
    ^ volumes
        remove: aVolume
        ifAbsent: [ self error: 'Помилка: Такого тому немає в цьому багатотомнику!' ]
]

{ #category : 'calculations' }
MultivolumeBook >> totalVolume [
    "Загальний обсяг багатотомника: сума сторінок усіх томів (для порожнього - 0)"
    ^ volumes inject: 0 into: [ :sum :each | sum + each pageCount ]
]

{ #category : 'accessing' }
MultivolumeBook >> volumeCount [
    "Кількість томів у багатотомнику"
    ^ volumes size
]

{ #category : 'accessing' }
MultivolumeBook >> volumes [
    "Повертає КОПІЮ колекції томів, щоб зовнішній код не міг обійти валідацію через volumes add:"
    ^ volumes copy
]

{ #category : 'accessing' }
MultivolumeBook >> volumes: aCollection [
    "Замінює томи. Валідація виконується до присвоєння, тому при помилці старий стан зберігається.
     Створюється нова колекція, тож зміни переданої колекції ззовні не впливають на багатотомник"
    | newVolumes |
    newVolumes := OrderedCollection new.
    aCollection do: [ :each |
        (each isKindOf: Volume) ifFalse: [
            self error: 'Помилка: Колекція має містити лише екземпляри класу Volume!'
        ].
        (newVolumes anySatisfy: [ :other | other volumeNumber = each volumeNumber ]) ifTrue: [
            self error: 'Помилка: У колекції є томи з однаковими номерами!'
        ].
        newVolumes add: each
    ].
    volumes := newVolumes
]
