package com.ifabijanovic.holonet.helper

/**
 * Created by feb on 19/03/2017.
 */
class StringHelper(private var string: String) {
    val value: String get() = this.string

    fun stripNewLinesAndTabs(): StringHelper {
        this.string = this.string.replace("\n", "").replace("\t", "")
        return this
    }

    fun trimSpaces(): StringHelper {
        this.string = this.string.trim(' ', '\n')
        return this
    }

    fun stripSpaces(): StringHelper {
        this.string = this.string.replace(" ", "")
        return this
    }

    fun collapseMultipleSpaces(): StringHelper {
        this.string = this.string.replace(Regex("[ ]+"), " ")
        return this
    }

    fun formatPostDate(): StringHelper {
        var value = this.collapseMultipleSpaces().string
        val separatorIndex = value.indexOf("| #")
        if (separatorIndex > 0) {
            value = value.substring(0, separatorIndex)
        }
        value = value.replace(" ,", ",")
        return StringHelper(value).trimSpaces()
    }
}
