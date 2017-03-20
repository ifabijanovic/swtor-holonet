package com.ifabijanovic.holonet.helper

import java.net.URL

/**
 * Created by feb on 19/03/2017.
 */
class URLComponents(val url: String) {
    fun queryValue(name: String): String? {
        val urlParts = this.url.split("?")
        if (urlParts.size < 2) { return null }

        val query = urlParts[1]

        val pairs = query.split("&")
        for (pair in pairs) {
            val components = pair.split("=")
            if (components.count() < 2) {
                continue
            }
            if (components[0] == name) {
                return components[1]
            }
        }
        return null
    }
}
