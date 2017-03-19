package com.ifabijanovic.holonet.helper

import org.junit.Assert
import org.junit.Test
import java.net.URL

/**
 * Created by feb on 19/03/2017.
 */
class URLComponentsTests {
    @Test
    fun queryValue_Success() {
        val url = URL("http://www.holonet.test?param=value")
        val value = URLComponents(url).queryValue("param")

        Assert.assertNotNull(value)
        Assert.assertEquals("value", value)
    }

    @Test
    fun queryValue_NoParameters() {
        val url = URL("http://www.holonet.test")
        val value = URLComponents(url).queryValue("param")

        Assert.assertNull(value)
    }

    @Test
    fun queryValue_MissingParameter() {
        val url = URL("http://www.holonet.test?param=value")
        val value = URLComponents(url).queryValue("otherParam")

        Assert.assertNull(value)
    }

    @Test
    fun queryValue_MultipleParameters() {
        val url = URL("http://www.holonet.test?param1=value1&param2=value2")
        val value1 = URLComponents(url).queryValue("param1")
        val value2 = URLComponents(url).queryValue("param2")

        Assert.assertNotNull(value1)
        Assert.assertEquals("value1", value1)
        Assert.assertNotNull(value2)
        Assert.assertEquals("value2", value2)
    }
}
