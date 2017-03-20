package com.ifabijanovic.holonet.forum.data

import com.ifabijanovic.holonet.forum.language.ForumLanguage
import org.jsoup.nodes.Element
import java.net.URL
import com.ifabijanovic.holonet.helper.URLComponents
import com.ifabijanovic.holonet.helper.StringHelper

/**
 * Created by feb on 19/03/2017.
 */
class ForumParser {
    fun linkParameter(linkElement: Element?, name: String): String? {
        val href = linkElement?.attr("href")
        if (href == null) { return null }

        val components = URLComponents(href)
        return components.queryValue(name)
    }

    fun integerContent(element: Element?): Int? {
        val text = element?.text()
        if (text == null) { return null }

        val value = StringHelper(text).stripNewLinesAndTabs().stripSpaces().value
        try {
            return value.toInt()
        } catch (e: NumberFormatException) {
            return null
        }
    }

    fun postDate(element: Element?): String? {
        val text = element?.text()
        if (text == null) { return null }

        return StringHelper(text).stripNewLinesAndTabs().formatPostDate().value
    }

    fun postNumber(element: Element?): Int? {
        val text = element?.text()
        if (text == null) { return null }

        val string = StringHelper(text).stripNewLinesAndTabs().trimSpaces().collapseMultipleSpaces().value
        val index = string.indexOf("| #")
        if (index <= 0) { return null }

        var numberString = StringHelper(string.substring(index + 3)).stripNewLinesAndTabs().stripSpaces().value

        val nextStrings = listOf(ForumLanguage.english.next, ForumLanguage.french.next, ForumLanguage.german.next)
        for (text in nextStrings) {
            val textIndex = numberString.indexOf(text)
            if (textIndex <= 0) { continue }
            numberString = numberString.substring(0, textIndex)
        }

        return numberString.toInt()
    }
}
