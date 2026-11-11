"
Модальне вікно «Нова книга».

Збирає дані форми (тип, назва, рік, автори, видавництва та поля, що залежать від типу) і створює книгу. Результат доступний через #book (nil, якщо книгу не створено).

Автори та видавництва, що вже є в бібліотеці, пропонуються у списку вибору БЕЗ повторів: об'єкти з однаковим іменем (без урахування регістру та зайвих пробілів) показуються як один запис. Так само один автор чи видавництво не можуть двічі потрапити в одну книгу.

Логіка відокремлена від системних діалогів (UIManager), тому її можна перевіряти тестами: #buildBook, #addAuthor:, #addPublisher:, #addVolumeNumber:pages:, #existingAuthors, #existingPublishers.

Public API and Key Messages:
- BookDialogPresenter on: aLibrary
- buildBook (збирає книгу з форми або сигналізує Error з поясненням)
- book (створена книга)
- existingAuthors / existingPublishers (унікальні за іменем)

Instance Variables:
	book	<Book | nil> Створена книга.
	library	<Library> Бібліотека, з якої беруться наявні автори та видавництва.
	(решта змінних - елементи форми)
"
Class {
	#name : 'BookDialogPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'library',
		'typeDropList',
		'titleInput',
		'yearInput',
		'authorsList',
		'addExistingAuthorBtn',
		'addNewAuthorBtn',
		'removeAuthorBtn',
		'publishersList',
		'addExistingPubBtn',
		'addNewPubBtn',
		'removePubBtn',
		'dynamicPresenter',
		'pagesInput',
		'illusInput',
		'volumesList',
		'addVolumeBtn',
		'removeVolumeBtn',
		'saveButton',
		'book'
	],
	#category : 'MyLibrary-UI-UI',
	#package : 'MyLibrary-UI',
	#tag : 'UI'
}

{ #category : 'actions' }
BookDialogPresenter >> addAuthor: anAuthor [
    "Додає автора до книги. Відповідає false, якщо автор з таким іменем уже доданий"
    | key |
    key := self keyOfAuthor: anAuthor.
    (authorsList items anySatisfy: [ :each | (self keyOfAuthor: each) = key ])
        ifTrue: [ ^ false ].
    authorsList items: (authorsList items copyWith: anAuthor).
    ^ true
]

{ #category : 'actions - sub dialog' }
BookDialogPresenter >> addNewVolume [
    | num title pages |
    num := UIManager default request: 'Номер тому (ціле число):'.
    num ifNil: [ ^ self ].
	 title := UIManager default request: 'Назва тому:'.
    title ifNil: [ ^ self ].
    pages := UIManager default request: 'Кількість сторінок:'.
    pages ifNil: [ ^ self ].
    [ self addVolumeNumber: num trimBoth asInteger title: title pages: pages trimBoth asInteger ]
        on: Error
        do: [ :error | UIManager default alert: error messageText ]
]

{ #category : 'actions' }
BookDialogPresenter >> addPublisher: aPublisher [
    "Додає видавництво до книги. Відповідає false, якщо видавництво з такою назвою вже додане"
    | key |
    key := self keyOfPublisher: aPublisher.
    (publishersList items anySatisfy: [ :each | (self keyOfPublisher: each) = key ])
        ifTrue: [ ^ false ].
    publishersList items: (publishersList items copyWith: aPublisher).
    ^ true
]

{ #category : 'actions' }
BookDialogPresenter >> addVolumeNumber: aNumber pages: aPageCount [
    "Додає том до списку томів. Некоректні дані або повторний номер тому дають Error"
    | volume |
    volume := Volume new
        volumeNumber: aNumber;
        pageCount: aPageCount;
        yourself.
    (volumesList items anySatisfy: [ :each | each volumeNumber = aNumber ])
        ifTrue: [ self error: 'Том з таким номером уже додано!' ].
    volumesList items: (volumesList items copyWith: volume).
    ^ volume
]

{ #category : 'actions' }
BookDialogPresenter >> addVolumeNumber: aNumber title: aTitle pages: aPageCount [
    "Додає том з назвою. Некоректні дані, порожня назва або повторний номер тому дають Error"
    | volume |
    (aTitle isNil or: [ aTitle trimBoth isEmpty ])
        ifTrue: [ self error: 'Введіть назву тому!' ].
    volume := Volume new
        volumeNumber: aNumber;
        titleVolume: aTitle trimBoth;
        pageCount: aPageCount;
        yourself.
    (volumesList items anySatisfy: [ :each | each volumeNumber = aNumber ])
        ifTrue: [ self error: 'Том з таким номером уже додано!' ].
    volumesList items: (volumesList items copyWith: volume).
    ^ volume
]

{ #category : 'accessing' }
BookDialogPresenter >> authorsList [
    ^ authorsList
]

{ #category : 'accessing' }
BookDialogPresenter >> book [
    ^ book
]

{ #category : 'actions' }
BookDialogPresenter >> buildBook [
    "Збирає книгу з даних форми. Якщо дані некоректні - сигналізує Error з поясненням"
    | type newBook title year |
    title := titleInput text trimBoth.
    title ifEmpty: [ self error: 'Введіть назву!' ].
    year := self integerFrom: yearInput minimum: 1 errorMessage: 'Введіть рік (додатне ціле число)!'.

    type := typeDropList selectedItem.
    newBook := type new.
    newBook title: title; year: (Year year: year).

    authorsList items do: [ :each | newBook addAuthor: each ].
    publishersList items do: [ :each | newBook addPublisher: each ].

    type == SingleVolumeBook ifTrue: [
        newBook pageCount: (self integerFrom: pagesInput minimum: 1 errorMessage: 'Введіть кількість сторінок (додатне ціле число)!') ].
    type == Monograph ifTrue: [
        newBook pageCount: (self integerFrom: pagesInput minimum: 1 errorMessage: 'Введіть кількість сторінок (додатне ціле число)!').
        newBook illustrationCount: (self integerFrom: illusInput minimum: 0 errorMessage: 'Введіть кількість ілюстрацій (ціле число, 0 або більше)!') ].
    type == MultivolumeBook ifTrue: [
        volumesList items ifEmpty: [ self error: 'Додайте хоча б один том!' ].
        volumesList items do: [ :each | newBook addVolume: each ] ].
    ^ newBook
]

{ #category : 'actions - sub dialog' }
BookDialogPresenter >> chooseExistingAuthor [
    | existing choice |
    existing := self existingAuthors.
    existing ifEmpty: [ ^ UIManager default inform: 'Немає наявних авторів!' ].
    choice := UIManager default
        chooseFrom: (existing collect: [ :each | each fullName ]) asArray
        values: existing
        title: 'Оберіть автора'.
    choice ifNil: [ ^ self ].
    (self addAuthor: choice)
        ifFalse: [ UIManager default inform: 'Такий автор уже є у списку.' ]
]

{ #category : 'actions - sub dialog' }
BookDialogPresenter >> chooseExistingPublisher [
    | existing choice |
    existing := self existingPublishers.
    existing ifEmpty: [ ^ UIManager default inform: 'Немає наявних видавництв!' ].
    choice := UIManager default
        chooseFrom: (existing collect: [ :each | each name ]) asArray
        values: existing
        title: 'Оберіть видавництво'.
    choice ifNil: [ ^ self ].
    (self addPublisher: choice)
        ifFalse: [ UIManager default inform: 'Таке видавництво вже є у списку.' ]
]

{ #category : 'connections' }
BookDialogPresenter >> connectPresenters [
    typeDropList whenSelectedItemChangedDo: [ :each | self updateDynamicPanel ].

    addExistingAuthorBtn action: [ self chooseExistingAuthor ].
    addNewAuthorBtn action: [ self createNewAuthor ].
    removeAuthorBtn action: [ self removeSelectedAuthor ].

    addExistingPubBtn action: [ self chooseExistingPublisher ].
    addNewPubBtn action: [ self createNewPublisher ].
    removePubBtn action: [ self removeSelectedPublisher ].

    addVolumeBtn action: [ self addNewVolume ].
    removeVolumeBtn action: [ self removeSelectedVolume ].

    saveButton action: [ self processForm ]
]

{ #category : 'actions - sub dialog' }
BookDialogPresenter >> createNewAuthor [
    | dialog existingAuthors |
    dialog := AuthorFormPresenter new.
    dialog openModal.
    
    dialog author ifNotNil: [ :newAuth |
        existingAuthors := authorsList items.
        (existingAuthors includes: newAuth)
            ifTrue: [ 
                UIManager default inform: 'Такий автор уже є у списку.' 
            ]
            ifFalse: [ 
                authorsList items: (existingAuthors asOrderedCollection 
                    add: newAuth; 
                    yourself) 
            ].
    ].
]

{ #category : 'actions - sub dialog' }
BookDialogPresenter >> createNewPublisher [
    | dialog existingPublishers |
    dialog := PublisherFormPresenter new.
    dialog openModal.
    
    dialog publisher ifNotNil: [ :newPub |
        existingPublishers := publishersList items.
        (existingPublishers includes: newPub)
            ifTrue: [ 
                UIManager default inform: 'Таке видавництво вже є у списку.' 
            ]
            ifFalse: [ 
                publishersList items: (existingPublishers asOrderedCollection 
                    add: newPub; 
                    yourself) 
            ].
    ].
]

{ #category : 'layout' }
BookDialogPresenter >> defaultLayout [
    | listsLayout |
    listsLayout := SpBoxLayout newLeftToRight
        spacing: 10;
        add: (SpBoxLayout newTopToBottom
            add: (self labelNamed: 'Автори:') expand: false;
            add: (SpBoxLayout newLeftToRight spacing: 5; add: addExistingAuthorBtn; add: addNewAuthorBtn; add: removeAuthorBtn; yourself) expand: false;
            add: authorsList;
            yourself);
        add: (SpBoxLayout newTopToBottom
            add: (self labelNamed: 'Видавництва:') expand: false;
            add: (SpBoxLayout newLeftToRight spacing: 5; add: addExistingPubBtn; add: addNewPubBtn; add: removePubBtn; yourself) expand: false;
            add: publishersList;
            yourself);
        yourself.

    ^ SpBoxLayout newTopToBottom
        spacing: 5;
        add: (self labelNamed: 'Тип видання:') expand: false; add: typeDropList expand: false;
        add: (self labelNamed: 'Назва:') expand: false; add: titleInput expand: false;
        add: (self labelNamed: 'Рік:') expand: false; add: yearInput expand: false;
        add: listsLayout;
        add: dynamicPresenter;
        add: saveButton expand: false;
        yourself
]

{ #category : 'queries' }
BookDialogPresenter >> existingAuthors [
    "Автори всіх книг бібліотеки; автори з однаковим іменем зведені до одного (першого)"
    | all |
    all := OrderedCollection new.
    library books do: [ :each | all addAll: each authors ].
    ^ self uniqueItems: all by: [ :each | self keyOfAuthor: each ]
]

{ #category : 'queries' }
BookDialogPresenter >> existingPublishers [
    "Видавництва всіх книг бібліотеки; з однаковою назвою зведені до одного (першого)"
    | all |
    all := OrderedCollection new.
    library books do: [ :each | all addAll: each publishers ].
    ^ self uniqueItems: all by: [ :each | self keyOfPublisher: each ]
]

{ #category : 'accessing' }
BookDialogPresenter >> illusInput [
    ^ illusInput
]

{ #category : 'initialization' }
BookDialogPresenter >> initializeDialogWindow: aDialogWindowPresenter [
    self initializeWindow: aDialogWindowPresenter.
    aDialogWindowPresenter 
        addButton: 'Скасувати' 
        do: [ :dialog | dialog close ].
]

{ #category : 'initialization' }
BookDialogPresenter >> initializePresenters [
    typeDropList := self newDropList
        items: { SingleVolumeBook . Monograph . MultivolumeBook };
        display: [ :each | each name ];
        yourself.
    typeDropList selectItem: SingleVolumeBook.
    titleInput := self newTextInput
        placeholder: 'Назва';
        yourself.
    yearInput := self newNumberInput
        placeholder: 'Рік (напр. 2024)';
        yourself.

    "Автори"
    authorsList := self newList
        display: [ :each | each fullName ];
        yourself.
    addExistingAuthorBtn := self newButton label: 'Вибрати'; iconName: #smallFind; yourself.
    addNewAuthorBtn := self newButton label: 'Новий'; iconName: #smallAdd; yourself.
    removeAuthorBtn := self newButton label: 'X'; iconName: #smallDelete; yourself.

    "Видавництва"
    publishersList := self newList
        display: [ :each | each name ];
        yourself.
    addExistingPubBtn := self newButton label: 'Вибрати'; iconName: #smallFind; yourself.
    addNewPubBtn := self newButton label: 'Нове'; iconName: #smallAdd; yourself.
    removePubBtn := self newButton label: 'X'; iconName: #smallDelete; yourself.

    "Динамічні поля (вставляються в макет залежно від типу книги)"
    dynamicPresenter := self instantiate: SpPresenter.
    pagesInput := self newNumberInput.
    illusInput := self newNumberInput.
    volumesList := self newList
        display: [ :each | 'Том ', each volumeNumber printString, ' «', each titleVolume, '» (', each pageCount printString, ' стор.)' ];
        yourself.
    addVolumeBtn := self newButton label: 'Додати том'; iconName: #smallAdd; yourself.
    removeVolumeBtn := self newButton label: 'Видалити том'; iconName: #smallDelete; yourself.

    saveButton := self newButton label: 'Створити книгу'; iconName: #smallOk; yourself.

    self updateDynamicPanel
]

{ #category : 'initialization' }
BookDialogPresenter >> initializeWindow: aWindowPresenter [
    aWindowPresenter title: 'Нова книга'; initialExtent: 650@700
]

{ #category : 'private' }
BookDialogPresenter >> integerFrom: aNumberInput minimum: aMinimum errorMessage: aString [
    "Ціле число з поля введення або Error з повідомленням aString"
    | value |
    value := aNumberInput number.
    (value isNumber and: [ value fractionPart = 0 ]) ifFalse: [ self error: aString ].
    value := value asInteger.
    value >= aMinimum ifFalse: [ self error: aString ].
    ^ value
]

{ #category : 'private' }
BookDialogPresenter >> keyOfAuthor: anAuthor [
    ^ anAuthor firstName trimBoth asLowercase, ' ', anAuthor lastName trimBoth asLowercase
]

{ #category : 'private' }
BookDialogPresenter >> keyOfPublisher: aPublisher [
    ^ aPublisher name trimBoth asLowercase
]

{ #category : 'private' }
BookDialogPresenter >> labelNamed: aString [
    ^ self newLabel
        label: aString;
        yourself
]

{ #category : 'accessing' }
BookDialogPresenter >> pagesInput [
    ^ pagesInput
]

{ #category : 'actions' }
BookDialogPresenter >> processForm [
    "Створює книгу; при помилці в даних показує повідомлення і лишає вікно відкритим"
    | newBook |
    [ newBook := self buildBook ]
        on: Error
        do: [ :error | ^ UIManager default alert: error messageText ].
    book := newBook.
    self withWindowDo: [ :aWindow | aWindow close ]
]

{ #category : 'accessing' }
BookDialogPresenter >> publishersList [
    ^ publishersList
]

{ #category : 'actions' }
BookDialogPresenter >> removeSelectedAuthor [
    authorsList selection selectedItem ifNotNil: [ :each |
        authorsList items: (authorsList items copyWithout: each) ]
]

{ #category : 'actions' }
BookDialogPresenter >> removeSelectedPublisher [
    publishersList selection selectedItem ifNotNil: [ :each |
        publishersList items: (publishersList items copyWithout: each) ]
]

{ #category : 'actions' }
BookDialogPresenter >> removeSelectedVolume [
    volumesList selection selectedItem ifNotNil: [ :each |
        volumesList items: (volumesList items copyWithout: each) ]
]

{ #category : 'initialization' }
BookDialogPresenter >> setModelBeforeInitialization: aLibrary [
    library := aLibrary
]

{ #category : 'accessing' }
BookDialogPresenter >> titleInput [
    ^ titleInput
]

{ #category : 'accessing' }
BookDialogPresenter >> typeDropList [
    ^ typeDropList
]

{ #category : 'private' }
BookDialogPresenter >> uniqueItems: aCollection by: aKeyBlock [
    "Залишає перший елемент із кожної групи елементів з однаковим ключем"
    | seenKeys result |
    seenKeys := Set new.
    result := OrderedCollection new.
    aCollection do: [ :each | | key |
        key := aKeyBlock value: each.
        (seenKeys includes: key) ifFalse: [
            seenKeys add: key.
            result add: each ] ].
    ^ result asArray
]

{ #category : 'actions - dynamic UI' }
BookDialogPresenter >> updateDynamicPanel [
    | newLayout selectedClass |
    selectedClass := typeDropList selectedItem.
    newLayout := SpBoxLayout newTopToBottom spacing: 5; yourself.

    selectedClass == SingleVolumeBook ifTrue: [
        newLayout
            add: (self labelNamed: 'Сторінки:') expand: false;
            add: pagesInput expand: false ].
    selectedClass == Monograph ifTrue: [
        newLayout
            add: (self labelNamed: 'Сторінки:') expand: false;
            add: pagesInput expand: false;
            add: (self labelNamed: 'Ілюстрації:') expand: false;
            add: illusInput expand: false ].
    selectedClass == MultivolumeBook ifTrue: [
        newLayout
            add: (SpBoxLayout newLeftToRight spacing: 5; add: (self labelNamed: 'Томи:'); add: addVolumeBtn expand: false; add: removeVolumeBtn expand: false; yourself) expand: false;
            add: volumesList ].

    dynamicPresenter layout: newLayout
]

{ #category : 'accessing' }
BookDialogPresenter >> volumesList [
    ^ volumesList
]

{ #category : 'accessing' }
BookDialogPresenter >> yearInput [
    ^ yearInput
]
