"
Монографія: книга, яка є різновидом однотомного видання (успадковується від SingleVolumeBook). Окрім звичайних сторінок, монографія містить спеціалізовані ілюстрації.

Обсяг (totalVolume) — розраховується як сума сторінок базового однотомника (super totalVolume) та кількості ілюстрацій (illustrationCount).
Встановити кількість ілюстрацій можна через illustrationCount:, який строго перевіряє, щоб число було цілим і невід'ємним (>= 0).
Оператори + і - у цьому класі перевизначені так, що вони працюють саме з ілюстраціями, а не зі сторінками (на відміну від базового класу). Оператор віднімання захищений від того, щоб кількість ілюстрацій стала від'ємною (не опускається нижче 0).

Instance Variables:illustrationCount	 Кількість ілюстрацій у монографії
"
Class {
	#name : 'Monograph',
	#superclass : 'SingleVolumeBook',
	#instVars : [
		'illustrationCount'
	],
	#category : 'MyLibrary-library',
	#package : 'MyLibrary',
	#tag : 'library'
}

{ #category : 'instance creation' }
Monograph class >> authors: authorCollection title: titleString publishers: publisherCollection year: aYear pageCount: anInteger illustrations: illusInteger [
    ^ (self authors: authorCollection title: titleString publishers: publisherCollection year: aYear pageCount: anInteger)
        illustrationCount: illusInteger;
        yourself
]

{ #category : 'instance creation' }
Monograph class >> bookFromDictionary: aDictionary [
    ^ (super bookFromDictionary: aDictionary)
        illustrationCount: (aDictionary at: 'illustrationCount' ifAbsent: [ nil ]);
        yourself
]

{ #category : 'constants' }
Monograph class >> defaultIllustrationCount [
    ^ 0
]

{ #category : 'arithmetic' }
Monograph >> + aNumber [
    self illustrationCount: self illustrationCount + aNumber.
    ^ self
]

{ #category : 'arithmetic' }
Monograph >> - aNumber [
    self illustrationCount: ((self illustrationCount - aNumber) max: self class defaultIllustrationCount).
    ^ self
]

{ #category : 'accessing' }
Monograph >> illustrationCount [
    ^ illustrationCount
]

{ #category : 'accessing' }
Monograph >> illustrationCount: aNumber [
    | finalCount |
    finalCount := aNumber ifNil: [ self class defaultIllustrationCount ].
    (finalCount isInteger and: [ finalCount >= 0 ]) ifFalse: [
        self error: 'Помилка: Кількість ілюстрацій має бути невід''ємним цілим числом!'
    ].
    illustrationCount := finalCount
]

{ #category : 'initialization' }
Monograph >> initialize [
    super initialize.
    self illustrationCount: nil.
]

{ #category : 'printing' }
Monograph >> printVolumeInfoOn: aStream [
    aStream 
        print: self pageCount; 
        nextPutAll: ' стор. та ';
        print: self illustrationCount;
        nextPutAll: ' іл. (загальний обсяг: ';
        print: self totalVolume;
        nextPutAll: ' стор., ';
        print: self printedSheets; 
        nextPutAll: ' друк. арк.)'
]

{ #category : 'calculations' }
Monograph >> totalVolume [
    ^ super totalVolume + self illustrationCount
]
