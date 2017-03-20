package com.ifabijanovic.holonet.forum.model

import com.ifabijanovic.holonet.app.model.Entity

/**
 * Created by feb on 19/03/2017.
 */
data class ForumCategory(
        override val id: Int,
        val iconUrl: String?,
        val title: String,
        val description: String?,
        val stats: String?,
        val lastPost: String?
): Entity {}
