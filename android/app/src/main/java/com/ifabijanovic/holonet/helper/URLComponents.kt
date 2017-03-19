package com.ifabijanovic.holonet.helper

import java.net.URL

/**
 * Created by feb on 19/03/2017.
 */
class URLComponents(val url: URL) {
    fun queryValue(name: String): String? {
        val query = this.url.query
        if (query == null) {
            return null
        }

        val pairs = this.url.query.split("&")
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
