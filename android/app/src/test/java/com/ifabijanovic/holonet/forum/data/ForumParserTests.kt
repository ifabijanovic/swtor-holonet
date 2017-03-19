package com.ifabijanovic.holonet.forum.data

import org.jsoup.nodes.Element
import org.junit.Assert
import org.junit.Test

/**
 * Created by feb on 19/03/2017.
 */
class ForumParserTests {
    @Test
    fun linkParameter_Success() {
        val link = Element("a")
        link.attr("href", "http://www.holonet.test?param=value")
        val param = ForumParser().linkParameter(link, "param")

        Assert.assertNotNull(param)
        Assert.assertEquals("value", param)
    }

    @Test
    fun linkParameter_ElementNull() {
        val param = ForumParser().linkParameter(null, "param")
        Assert.assertNull(param)
    }

    @Test
    fun linkParameter_MissingParameter() {
        val link = Element("a")
        link.attr("href", "http://www.holonet.test")
        val param = ForumParser().linkParameter(link, "param")

        Assert.assertNull(param)
    }

    @Test
    fun linkParameter_MultipleParameters() {
        val link = Element("a")
        link.attr("href", "http://www.holonet.test?param1=value1&param2=value2")
        val param = ForumParser().linkParameter(link, "param2")

        Assert.assertNotNull(param)
        Assert.assertEquals("value2", param)
    }

    //

    @Test
    fun integerContent_Success() {
        val html = Element("div")
        html.text("123")
        val value = ForumParser().integerContent(html)

        Assert.assertEquals(123, value)
    }

    @Test
    fun integerContent_Nested() {
        val parent = Element("div")
        val child = Element("div")
        parent.appendChild(child)
        child.text("123")
        val value = ForumParser().integerContent(parent)

        Assert.assertEquals(123, value)
    }

    @Test
    fun integerContent_ElementNull() {
        val value = ForumParser().integerContent(null)
        Assert.assertNull(value)
    }

    @Test
    fun integerContent_NoInteger() {
        val html = Element("div")
        html.text("some text")
        val value = ForumParser().integerContent(html)

        Assert.assertNull(value)
    }

    @Test
    fun integerContent_MixedContent() {
        val html = Element("div")
        html.text("some text with 123 numbers 456 ")
        val value = ForumParser().integerContent(html)

        Assert.assertNull(value)
    }

    //

    @Test
    fun postDate_Success() {
        val html = Element("div")
        html.text("10.10.2014 , 10:10 AM | #1")
        val value = ForumParser().postDate(html)

        Assert.assertEquals("10.10.2014, 10:10 AM", value)
    }

    @Test
    fun postDate_Nested() {
        val parent = Element("div")
        val child = Element("div")
        parent.appendChild(child)
        child.text("10.10.2014 , 10:10 AM | #1")
        val value = ForumParser().postDate(parent)

        Assert.assertEquals("10.10.2014, 10:10 AM", value)
    }

    @Test
    fun postDate_ElementNull() {
        val value = ForumParser().postDate(null)
        Assert.assertNull(value)
    }

    //

    @Test
    fun postNumber_Success() {
        val html = Element("div")
        html.text("10.10.2014 , 10:10 AM | #17")
        val value = ForumParser().postNumber(html)

        Assert.assertEquals(17, value)
    }

    @Test
    fun postNumber_Nested() {
        val parent = Element("div")
        val child = Element("div")
        parent.appendChild(child)
        child.text("10.10.2014 , 10:10 AM | #77")
        val value = ForumParser().postNumber(parent)

        Assert.assertEquals(77, value)
    }

    @Test
    fun postNumber_ElementNull() {
        val value = ForumParser().postNumber(null)
        Assert.assertNull(value)
    }

    @Test
    fun postNumber_DevWithNextMultipleLanguages() {
        val en = Element("div")
        en.text("10.10.2014 , 10:10 AM | #5 Next")
        val enValue = ForumParser().postNumber(en)
        Assert.assertEquals(5, enValue)

        val fr = Element("div")
        fr.text("10.10.2014 , 10:10 AM | #77 Suivante")
        val frValue = ForumParser().postNumber(fr)
        Assert.assertEquals(77, frValue)

        val de = Element("div")
        de.text("10.10.2014 , 10:10 AM | #203 Nächste")
        val deValue = ForumParser().postNumber(de)
        Assert.assertEquals(203, deValue)
    }
}
