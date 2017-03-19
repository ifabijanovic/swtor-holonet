package com.ifabijanovic.holonet.forum.model

import com.ifabijanovic.holonet.app.model.Entity

/**
 * Created by feb on 19/03/2017.
 */
data class ForumPost(
        override val id: Int,
        val avatarUrl: String?,
        val username: String,
        val date: String,
        val postNumber: Int?,
        val isBiowarePost: Boolean,
        val text: String,
        val signature: String?): Entity {
    constructor(
            id: Int,
            username: String,
            date: String,
            postNumber: Int?,
            isBiowarePost: Boolean,
            text: String): this(id, null, username, date, postNumber, isBiowarePost, text, null)
}
