package com.ifabijanovic.holonet.helper

import org.junit.Assert
import org.junit.Test

/**
 * Created by feb on 19/03/2017.
 */
class StringHelperTests {
    @Test
    fun stripNewLinesAndTabs_Success() {
        val string = "some text\nwith new lines\tand tabs\n\t\n"
        val output = StringHelper(string).stripNewLinesAndTabs().value

        Assert.assertEquals("some textwith new linesand tabs", output)
    }

    @Test
    fun stripNewLinesAndTabs_NoSpecialCharacters() {
        val string = "some text without new lines or tabs"
        val output = StringHelper(string).stripNewLinesAndTabs().value

        Assert.assertEquals("some text without new lines or tabs", output)
    }

    @Test
    fun stripNewLinesAndTabs_EmptyString() {
        val string = ""
        val output = StringHelper(string).stripNewLinesAndTabs().value

        Assert.assertEquals("", output)
    }

    @Test
    fun trimSpaces_Success() {
        val string = "\nsome   text with spaces "
        val output = StringHelper(string).trimSpaces().value

        Assert.assertEquals("some   text with spaces", output)
    }

    @Test
    fun trimSpaces_NoSpacesToTrim() {
        val string = "some   text with spaces"
        val output = StringHelper(string).trimSpaces().value

        Assert.assertEquals(string, output)
    }

    @Test
    fun trimSpaces_EmptyString() {
        val string = ""
        val output = StringHelper(string).trimSpaces().value

        Assert.assertEquals("", output)
    }

    @Test
    fun stripSpaces_Success() {
        val string = "     some   text with spaces"
        val output = StringHelper(string).stripSpaces().value

        Assert.assertEquals("sometextwithspaces", output)
    }

    @Test
    fun stripSpaces_NoSpaces() {
        val string = "sometextwithoutspaces"
        val output = StringHelper(string).stripSpaces().value

        Assert.assertEquals(string, output)
    }

    @Test
    fun stripSpaces_EmptyString() {
        val string = ""
        val output = StringHelper(string).stripSpaces().value

        Assert.assertEquals("", output)
    }

    @Test
    fun collapseMultipleSpaces_Success() {
        val string = "     some    text with   a     lot of spaces      "
        val output = StringHelper(string).collapseMultipleSpaces().value

        Assert.assertEquals(" some text with a lot of spaces ", output)
    }

    @Test
    fun collapseMultipleSpaces_NoSpaces() {
        val string = "sometextwithoutspaces"
        val output = StringHelper(string).collapseMultipleSpaces().value

        Assert.assertEquals(string, output)
    }

    @Test
    fun collapseMultipleSpaces_EmptyString() {
        val string = ""
        val output = StringHelper(string).collapseMultipleSpaces().value

        Assert.assertEquals("", output)
    }

    @Test
    fun formatPostDate_Success() {
        val string = "10.10.2014 , 10:10 AM | #1"
        val output = StringHelper(string).formatPostDate().value

        Assert.assertEquals("10.10.2014, 10:10 AM", output)
    }

    @Test
    fun formatPostDate_EmptyString() {
        val string = ""
        val output = StringHelper(string).formatPostDate().value

        Assert.assertEquals("", output)
    }
}
