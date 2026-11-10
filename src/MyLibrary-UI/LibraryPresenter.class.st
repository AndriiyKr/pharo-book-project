"
Головне вікно бібліотеки: таблиця книг, пошук, додавання, видалення, перегляд, ревізія старих книг, збереження та завантаження (файл у форматах STON / текст / StoreString та база даних Voyage).

Вікно працює з бібліотекою, яку передано через #on:. Збереження в БД під новою назвою створює копію бібліотеки, і вікно далі працює з нею; завантаження з файлу чи БД підміняє бібліотеку вікна.

Логіка відокремлена від системних діалогів (UIManager), тому її можна перевіряти тестами:
- #filterByAuthor:, #filterByYear:, #updateUI, #removeSelectedBook
- #saveToFileNamed:format:, #loadFromFileNamed:format:
- #saveToDatabaseAs:, #loadFromDatabaseNamed:

Public API and Key Messages:
- LibraryPresenter on: aLibrary (відкривається повідомленням #open)
- library (бібліотека, з якою працює вікно; може змінитися після завантаження чи збереження під новою назвою)

Instance Variables:
	booksTable	<SpTablePresenter> Таблиця книг.
	library	<Library> Бібліотека, що відображається.
	statusBar	<SpLabelPresenter> Рядок стану.
	(решта змінних - кнопки)
"
Class {
	#name : 'LibraryPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'library',
		'booksTable',
		'addButton',
		'removeButton',
		'viewButton',
		'searchAuthorButton',
		'searchYearButton',
		'resetButton',
		'replaceButton',
		'saveFileButton',
		'loadFileButton',
		'saveDbButton',
		'loadDbButton',
		'statusBar'
	],
	#category : 'MyLibrary-UI-UI',
	#package : 'MyLibrary-UI',
	#tag : 'UI'
}

{ #category : 'accessing' }
LibraryPresenter >> booksTable [
    ^ booksTable
]

{ #category : 'connections' }
LibraryPresenter >> connectPresenters [
    addButton action: [ self openAddBookDialog ].
    removeButton action: [ self removeSelectedBook ].
    viewButton action: [ self viewSelectedBook ].

    searchAuthorButton action: [ self searchByAuthor ].
    searchYearButton action: [ self searchByYear ].
    resetButton action: [ self updateUI ].

    replaceButton action: [ self reviewOldBooks ].
    saveFileButton action: [ self saveToFile ].
    loadFileButton action: [ self loadFromFile ].
    saveDbButton action: [ self saveToDatabase ].
    loadDbButton action: [ self loadFromDatabase ]
]

{ #category : 'layout' }
LibraryPresenter >> defaultLayout [
    | topBar bottomBar |
    topBar := SpBoxLayout newLeftToRight
        spacing: 5;
        add: addButton; add: removeButton; add: viewButton;
        add: (self labelNamed: '|') width: 20;
        add: searchAuthorButton; add: searchYearButton; add: resetButton;
        yourself.

    bottomBar := SpBoxLayout newLeftToRight
        spacing: 5;
        add: replaceButton;
        add: (self labelNamed: '|') width: 20;
        add: saveFileButton; add: loadFileButton; add: saveDbButton; add: loadDbButton;
        yourself.

    ^ SpBoxLayout newTopToBottom
        spacing: 5;
        add: topBar expand: false;
        add: booksTable;
        add: bottomBar expand: false;
        add: statusBar expand: false;
        yourself
]

{ #category : 'private' }
LibraryPresenter >> ensureRepository [
    "Якщо репозиторій Voyage ще не налаштований - використовуємо БД у пам'яті"
    VORepository current ifNil: [ Library useInMemoryDatabase ]
]

{ #category : 'actions' }
LibraryPresenter >> filterByAuthor: aString [
    "Залишає у таблиці книги, у яких ім'я чи прізвище автора містить aString (без урахування регістру)"
    | fragment |
    fragment := aString trimBoth asLowercase.
    self showFound: (library books select: [ :each |
        each authors anySatisfy: [ :author |
            author fullName asLowercase includesSubstring: fragment ] ])
]

{ #category : 'actions' }
LibraryPresenter >> filterByYear: anInteger [
    "Залишає у таблиці книги, видані в рік anInteger"
    self showFound: (library booksByYear: (Year year: anInteger))
]

{ #category : 'initialization' }
LibraryPresenter >> initializePresenters [
    "Бібліотеку НЕ створюємо тут: вона передається через #on: (див. #setModelBeforeInitialization:).
     Репозиторій Voyage налаштовується ліниво, лише коли потрібна БД (див. #ensureRepository)"
    booksTable := self newTable.
    booksTable
        addColumn: (SpStringTableColumn title: 'Назва' evaluated: [ :each | each title ]);
        addColumn: (SpStringTableColumn title: 'Рік' evaluated: [ :each | each year year asString ]);
        addColumn: (SpStringTableColumn title: 'Автори' evaluated: [ :each |
            String streamContents: [ :s | each printAuthorsOn: s ] ]);
        addColumn: (SpStringTableColumn title: 'Тип' evaluated: [ :each | each class name ]);
        addColumn: (SpStringTableColumn title: 'Обсяг' evaluated: [ :each | each totalVolume asString ]).

    "Верхня панель (керування та пошук)"
    addButton := self newButton label: 'Додати'; iconName: #smallAdd; yourself.
    removeButton := self newButton label: 'Видалити'; iconName: #smallDelete; yourself.
    viewButton := self newButton label: 'Переглянути'; iconName: #smallFind; yourself.

    searchAuthorButton := self newButton label: 'Пошук автора'; iconName: #smallSearch; yourself.
    searchYearButton := self newButton label: 'Пошук за роком'; iconName: #smallSearch; yourself.
    resetButton := self newButton label: 'Скинути фільтр'; iconName: #smallUpdate; yourself.

    "Нижня панель (дані)"
    replaceButton := self newButton label: 'Ревізія старих книг'; iconName: #smallQuestion; yourself.
    saveFileButton := self newButton label: 'Зберегти у файл'; iconName: #smallSave; yourself.
    loadFileButton := self newButton label: 'Відкрити з файлу'; iconName: #smallOpen; yourself.
    saveDbButton := self newButton label: 'Зберегти в БД'; iconName: #smallDatabase; yourself.
    loadDbButton := self newButton label: 'Відкрити з БД'; iconName: #smallOpen; yourself.

    statusBar := self newLabel.
    self updateUI
]

{ #category : 'initialization' }
LibraryPresenter >> initializeWindow: aWindowPresenter [
    aWindowPresenter
        title: (library name ifNil: [ 'Сучасна Бібліотека' ]);
        initialExtent: 950@550;
        windowIcon: (self iconNamed: #book)
]

{ #category : 'private' }
LibraryPresenter >> labelNamed: aString [
    ^ self newLabel
        label: aString;
        yourself
]

{ #category : 'accessing' }
LibraryPresenter >> library [
    ^ library
]

{ #category : 'accessing' }
LibraryPresenter >> loadFormats [
    "Формати завантаження з файлу (номер = індекс у цьому масиві)"
    ^ #('STON' 'StoreString')
]

{ #category : 'actions - dialogs' }
LibraryPresenter >> loadFromDatabase [
    | targetName |
    targetName := UIManager default
        request: 'Введіть назву бібліотеки для завантаження з БД:'
        initialAnswer: (library name ifNil: [ 'Моя бібліотека' ]).
    targetName isEmptyOrNil ifTrue: [ ^ self ].
    [ (self loadFromDatabaseNamed: targetName trimBoth)
        ifTrue: [ UIManager default inform: 'Бібліотеку "', targetName, '" успішно завантажено з БД!' ]
        ifFalse: [ UIManager default alert: 'Помилка: Бібліотеку з назвою "', targetName, '" не знайдено в БД!' ] ]
        on: Error
        do: [ :error | UIManager default alert: 'Помилка роботи з БД: ', error messageText ]
]

{ #category : 'actions - database' }
LibraryPresenter >> loadFromDatabaseNamed: aName [
    "Підміняє бібліотеку вікна бібліотекою з БД. Відповідає false, якщо такої назви в БД немає"
    | loaded |
    self ensureRepository.
    loaded := Library loadFromDatabase: aName.
    loaded ifNil: [ ^ false ].
    library := loaded.
    self updateUI.
    ^ true
]

{ #category : 'actions - dialogs' }
LibraryPresenter >> loadFromFile [
    | formatIndex fileName |
    formatIndex := UIManager default
        chooseFrom: self loadFormats
        title: 'Оберіть формат завантаження:'.
    formatIndex = 0 ifTrue: [ ^ self ].

    fileName := UIManager default request: 'Введіть ім''я файлу:' initialAnswer: 'library_data'.
    fileName isEmptyOrNil ifTrue: [ ^ self ].

    [ self loadFromFileNamed: fileName trimBoth format: formatIndex.
      UIManager default inform: 'Успішно завантажено!' ]
        on: Error
        do: [ :error | UIManager default alert: 'Не вдалося відкрити файл: ', error messageText ]
]

{ #category : 'actions - files' }
LibraryPresenter >> loadFromFileNamed: aBaseName format: aFormatIndex [
    "Завантажує бібліотеку з файлу aBaseName + розширення формату (1 - STON, 2 - StoreString).
     Бібліотека вікна підміняється лише після успішного завантаження; при помилці лишається старою"
    | loaded |
    aFormatIndex = 1 ifTrue: [
        loaded := Library new.
        loaded loadFromSTON: aBaseName, '.ston' ].
    aFormatIndex = 2 ifTrue: [
        loaded := Library loadFromStoreString: aBaseName, '.txt' ].
    (loaded isKindOf: Library) ifFalse: [ self error: 'Не вдалося прочитати бібліотеку з файлу!' ].
    library := loaded.
    self updateUI
]

{ #category : 'actions - dialogs' }
LibraryPresenter >> openAddBookDialog [
    | dialog |
    dialog := BookDialogPresenter on: library.
    dialog openModal.
    dialog book ifNotNil: [ :newBook |
        library addBook: newBook.
        self updateUI ]
]

{ #category : 'actions' }
LibraryPresenter >> removeSelectedBook [
    booksTable selection selectedItem ifNotNil: [ :selected |
        library removeBook: selected.
        self updateUI ]
]

{ #category : 'actions - dialogs' }
LibraryPresenter >> reviewOldBooks [
    | yearStr year |
    yearStr := UIManager default request: 'Введіть рік. Усі книги, видані ДО цього року, будуть запропоновані до списання:'.
    (yearStr isNil or: [ yearStr trimBoth isEmpty ]) ifTrue: [ ^ self ].

    year := yearStr trimBoth asInteger.
    year ifNil: [ ^ UIManager default alert: 'Будь ласка, введіть коректне число!' ].
    library reviewOldBooks: (Year year: year).
    self updateUI
]

{ #category : 'accessing' }
LibraryPresenter >> saveFormats [
    "Формати збереження у файл (номер = індекс у цьому масиві)"
    ^ #('STON' 'Звичайний текст (експорт)' 'StoreString')
]

{ #category : 'actions - dialogs' }
LibraryPresenter >> saveToDatabase [
    | targetName |
    targetName := UIManager default
        request: 'Введіть назву для збереження бібліотеки в БД:'
        initialAnswer: (library name ifNil: [ 'Моя бібліотека' ]).
    targetName isEmptyOrNil ifTrue: [ ^ self ].
    [ self saveToDatabaseAs: targetName trimBoth.
      UIManager default inform: 'Бібліотеку "', targetName, '" успішно збережено в БД!' ]
        on: Error
        do: [ :error | UIManager default alert: 'Помилка підключення до БД (перевірте налаштування Voyage): ', error messageText ]
]

{ #category : 'actions - database' }
LibraryPresenter >> saveToDatabaseAs: aName [
    "Зберігає бібліотеку в БД під назвою aName. Якщо назва нова - зберігається копія (Save As),
     і вікно далі працює з нею. Відповідає збережену бібліотеку"
    | target |
    self ensureRepository.
    (library name isNil or: [ library name = aName ])
        ifTrue: [
            library name: aName.
            target := library ]
        ifFalse: [
            target := Library new.
            target name: aName.
            library books do: [ :each | target addBook: each ] ].
    target saveToDatabase.
    library := target.
    ^ target
]

{ #category : 'actions - dialogs' }
LibraryPresenter >> saveToFile [
    | formatIndex fileName |
    formatIndex := UIManager default
        chooseFrom: self saveFormats
        title: 'Оберіть формат збереження:'.
    formatIndex = 0 ifTrue: [ ^ self ].

    fileName := UIManager default request: 'Введіть ім''я файлу:' initialAnswer: 'library_data'.
    fileName isEmptyOrNil ifTrue: [ ^ self ].

    [ self saveToFileNamed: fileName trimBoth format: formatIndex.
      UIManager default inform: 'Успішно збережено!' ]
        on: Error
        do: [ :error | UIManager default alert: 'Не вдалося зберегти файл: ', error messageText ]
]

{ #category : 'actions - files' }
LibraryPresenter >> saveToFileNamed: aBaseName format: aFormatIndex [
    "Зберігає бібліотеку у файл aBaseName + розширення формату (1 - STON, 2 - текст, 3 - StoreString)"
    aFormatIndex = 1 ifTrue: [ ^ library saveToSTON: aBaseName, '.ston' ].
    aFormatIndex = 2 ifTrue: [ ^ library exportToText: aBaseName, '.txt' ].
    aFormatIndex = 3 ifTrue: [ ^ library saveToStoreString: aBaseName, '.txt' ].
    self error: 'Невідомий формат збереження!'
]

{ #category : 'actions - dialogs' }
LibraryPresenter >> searchByAuthor [
    | searchStr |
    searchStr := UIManager default request: 'Введіть фрагмент імені або прізвища автора:'.
    (searchStr isNil or: [ searchStr trimBoth isEmpty ]) ifTrue: [ ^ self ].
    self filterByAuthor: searchStr
]

{ #category : 'actions - dialogs' }
LibraryPresenter >> searchByYear [
    | yearStr year |
    yearStr := UIManager default request: 'Введіть рік видання (наприклад, 2024):'.
    (yearStr isNil or: [ yearStr trimBoth isEmpty ]) ifTrue: [ ^ self ].

    year := yearStr trimBoth asInteger.
    year ifNil: [ ^ UIManager default alert: 'Будь ласка, введіть коректне число!' ].
    self filterByYear: year
]

{ #category : 'initialization' }
LibraryPresenter >> setModelBeforeInitialization: aLibrary [
    library := aLibrary
]

{ #category : 'private' }
LibraryPresenter >> showFound: aCollection [
    "Показує у таблиці лише знайдені книги"
    booksTable items: aCollection asArray.
    statusBar label: ('Пошук: знайдено {1} книг' format: { aCollection size })
]

{ #category : 'accessing' }
LibraryPresenter >> statusBar [
    ^ statusBar
]

{ #category : 'actions' }
LibraryPresenter >> updateUI [
    booksTable items: library books asArray.
    statusBar label: ('Всього примірників: {1} | Загальний обсяг друк. аркушів: {2}'
        format: { library totalCopies . library totalPrintedSheets })
]

{ #category : 'actions' }
LibraryPresenter >> viewSelectedBook [
    | selected |
    selected := booksTable selection selectedItem.
    selected ifNil: [ ^ UIManager default alert: 'Оберіть книгу для перегляду!' ].
    (BookInfoPresenter on: selected) open
]
