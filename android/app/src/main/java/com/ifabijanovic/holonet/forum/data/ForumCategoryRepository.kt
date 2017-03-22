package com.ifabijanovic.holonet.forum.data

import com.ifabijanovic.holonet.app.model.Settings
import com.ifabijanovic.holonet.forum.language.ForumLanguage
import com.ifabijanovic.holonet.forum.model.ForumCategory
import com.ifabijanovic.holonet.forum.model.ForumMaintenanceException
import com.ifabijanovic.holonet.helper.StringHelper
import io.reactivex.Observable
import io.reactivex.schedulers.Schedulers
import org.jsoup.Jsoup
import org.jsoup.nodes.Element

/**
 * Created by feb on 20/03/2017.
 */
interface ForumCategoryRepository {
    fun categories(language: ForumLanguage): Observable<List<ForumCategory>>
    fun categories(language: ForumLanguage, parent: ForumCategory): Observable<List<ForumCategory>>
}

class DefaultForumCategoryRepository(parser: ForumParser, service: ForumService, settings: Settings): ForumRepositoryBase(parser, service, settings), ForumCategoryRepository {
    override fun categories(language: ForumLanguage): Observable<List<ForumCategory>> {
        val localizedSettings = this.localizedSettings(language)
        return this.categories(localizedSettings.pathPrefix, localizedSettings.rootCategoryId)
    }

    override fun categories(language: ForumLanguage, parent: ForumCategory): Observable<List<ForumCategory>> {
        val localizedSettings = this.localizedSettings(language)
        return this.categories(localizedSettings.pathPrefix, parent.id)
    }

    private fun categories(language: String, categoryId: Int): Observable<List<ForumCategory>> {
        return this.service
                .category(language, categoryId)
                .subscribeOn(Schedulers.io())
                .observeOn(Schedulers.computation())
                .map { html ->
                    val items = this.parse(html)
                    if (items.isEmpty() && this.isMaintenance(html)) {
                        throw ForumMaintenanceException()
                    }
                    return@map items
                }
    }

    private fun parse(html: String): List<ForumCategory> {
        val items = mutableListOf<ForumCategory>()

        Jsoup.parse(html)
                .select(".forumCategory > .subForum")
                .mapNotNullTo(items) { this.parseCategory(it) }

        return items.toList()
    }

    private fun parseCategory(element: Element): ForumCategory? {
        // Id & Title
        val titleElement = element.select(".resultTitle > a")?.first()
        val idString = this.parser.linkParameter(titleElement, this.settings.categoryQueryParam)
        var id: Int?
        try {
            id = idString?.toInt()
        } catch (e: Exception) {
            id = null
        }
        val title = titleElement?.text()

        // Icon
        var iconUrl: String? = null
        val thumbElement = element.select(".thumbBackground")?.first()
        if (thumbElement != null) {
            val iconStyle = thumbElement.attr("style")
            if (iconStyle != null) {
                val startString = "url("
                val start = iconStyle.indexOf(startString, 0, true)
                val end = iconStyle.indexOf(")", 0, true)
                iconUrl = iconStyle.substring(start + startString.count(), end)
            }
        }

        // Description
        val description = element.select(".resultText")?.first()?.text()

        // Stats & Last post
        var stats: String? = null
        var lastPost: String? = null
        val subTextElements = element.select(".resultSubText")

        if (subTextElements.size > 0) {
            stats = subTextElements[0].text()
        }

        if (subTextElements.size > 1) {
            lastPost = subTextElements[1].text()
        }

        if (id == null) { return null }
        if (title == null) { return null }

        val finalTitle = StringHelper(title).stripNewLinesAndTabs().trimSpaces().collapseMultipleSpaces().value
        val finalDescription = if (description != null) StringHelper(description).trimSpaces().value else null
        val finalStats = if (stats != null) StringHelper(stats).stripNewLinesAndTabs().trimSpaces().collapseMultipleSpaces().value else null
        val finalLastPost = if (lastPost != null) StringHelper(lastPost).stripNewLinesAndTabs().trimSpaces().collapseMultipleSpaces().value else null

        return ForumCategory(id, iconUrl, finalTitle, finalDescription, finalStats, finalLastPost)
    }
}
