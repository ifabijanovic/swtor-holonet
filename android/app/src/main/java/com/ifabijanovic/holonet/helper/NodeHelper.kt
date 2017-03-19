package com.ifabijanovic.holonet.helper

import org.jsoup.nodes.Node

/**
 * Created by feb on 19/03/2017.
 */
class NodeHelper(val node: Node) {
    fun hasAttribute(name: String): Boolean {
        return this.node.attr(name) != null
    }

    fun hasAttributeWithValue(name: String, value: String): Boolean {
        return this.node.attr(name) == value
    }

    fun hasAttributeContainingValue(name: String, value: String): Boolean {
        return this.node.attr(name)?.contains(value, true) ?: false
    }
}
