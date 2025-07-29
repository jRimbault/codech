#include "Struct.h"
#include "struct/List.c"
#include "struct/HashMap.c"


const struct Library MyLib = {
    .List = {
        .new = newList,
        .free = freeList,
        .length = listLength,
        .add = addToList,
        .get = getNodeFromList,
        .remove = removeFromList,
        .contains = listContains,
        .invert = invertList,
        .merge = mergeLists,
        .iter = iterateOverList,
        .toString = listToString,
    },
    .Hashmap = {
        .new = newHashMap,
        .put = addNewElement,
        .get = getElement,
        .iter = iteratorOverMap,
        .remove = removeElement,
        .free = freeHashMap,
        .display = displayHashMap,
        .info = hashMapInfos,
        .size = getHashMapSize,
        .capacity = getHashMapCapacity,
    },
};
