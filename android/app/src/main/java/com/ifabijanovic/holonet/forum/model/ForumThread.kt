package com.ifabijanovic.holonet.forum.model

import com.ifabijanovic.holonet.app.model.Entity

/**
 * Created by feb on 19/03/2017.
 */
data class ForumThread(
        override val id: Int,
        val title: String,
        val lastPostDate: String,
        val author: String,
        val replies: Int,
        val views: Int,
        val hasBiowareReply: Boolean,
        val isSticky: Boolean,
        val isDevTracker: Boolean,
        val loadIndex: Int): Entity {

    constructor(
            id: Int,
            title: String,
            lastPostDate: String,
            author: String,
            replies: Int,
            views: Int,
            hasBiowareReply: Boolean,
            isSticky: Boolean): this(id, title, lastPostDate, author, replies, views, hasBiowareReply, isSticky, false, 0)

    constructor(
            id: Int,
            title: String,
            lastPostDate: String,
            author: String,
            replies: Int,
            views: Int): this(id, title, lastPostDate, author, replies, views, false, false, false, 0)
}

fun devTrackerThread(): ForumThread {
    return ForumThread(0, "Dev tracker", "", "", 0, 0, false, false, true, 0)
}
