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
    ^ (self authors: authorCollection title: titleString publishers: publisherCollection year: aYear)
        volumes: volumeCollection;
        yourself
]

{ #category : 'arithmetic' }
MultivolumeBook >> + aVolume [
    (aVolume isKindOf: Volume) ifFalse: [ 
        self error: 'Помилка: До багатотомника можна додавати лише об’єкти класу Volume!' 
    ].
    self volumes add: aVolume.
    ^ self
]

{ #category : 'arithmetic' }
MultivolumeBook >> - aVolume [
    self volumes remove: aVolume ifAbsent: [ 
        self error: 'Помилка: Такого тому немає в цьому багатотомнику!' 
    ].
    ^ self
]

{ #category : 'printing' }
MultivolumeBook >> printVolumeInfoOn: aStream [
    aStream 
        nextPutAll: self volumes size;
        nextPutAll: ' томів (загалом ';
        nextPutAll: self totalVolume; 
        nextPutAll: ' стор., ';
        nextPutAll: self printedSheets; 
        nextPutAll: ' друк. арк.)'
]

{ #category : 'calculations' }
MultivolumeBook >> totalVolume [
    ^ self volumes 
        ifEmpty: [ 0 ] 
        ifNotEmpty: [ self volumes sum: [ :eachVolume | eachVolume pageCount ] ]
]

{ #category : 'accessing' }
MultivolumeBook >> volumes [
    ^ volumes ifNil: [ volumes := OrderedCollection new ]
]

{ #category : 'accessing' }
MultivolumeBook >> volumes: aCollection [
    aCollection do: [ :each | 
        (each isKindOf: Volume) ifFalse: [ 
            self error: 'Помилка: Колекція має містити лише екземпляри класу Volume!' 
        ]
    ].
    volumes := aCollection asOrderedCollection
]
