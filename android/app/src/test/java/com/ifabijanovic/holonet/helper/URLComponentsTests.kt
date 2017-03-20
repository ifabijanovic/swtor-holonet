package com.ifabijanovic.holonet.helper

import org.junit.Assert.*
import org.junit.Test

/**
 * Created by feb on 19/03/2017.
 */
class URLComponentsTests {
    @Test
    fun queryValue_Success() {
        val url = "http://www.holonet.test?param=value"
        val value = URLComponents(url).queryValue("param")

        assertNotNull(value)
        assertEquals("value", value)
    }

    @Test
    fun queryValue_NoParameters() {
        val url = "http://www.holonet.test"
        val value = URLComponents(url).queryValue("param")

        assertNull(value)
    }

    @Test
    fun queryValue_MissingParameter() {
        val url = "http://www.holonet.test?param=value"
        val value = URLComponents(url).queryValue("otherParam")

        assertNull(value)
    }

    @Test
    fun queryValue_MultipleParameters() {
        val url = "http://www.holonet.test?param1=value1&param2=value2"
        val value1 = URLComponents(url).queryValue("param1")
        val value2 = URLComponents(url).queryValue("param2")

        assertNotNull(value1)
        assertEquals("value1", value1)
        assertNotNull(value2)
        assertEquals("value2", value2)
    }

    @Test
    fun queryValue_MalformedUrl() {
        val url = "somewhere/test?param=value"
        val value = URLComponents(url).queryValue("param")

        assertNotNull(value)
        assertEquals("value", value)
    }
}
