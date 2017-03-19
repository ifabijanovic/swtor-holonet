package com.ifabijanovic.holonet.forum.data

import io.reactivex.Observable
import retrofit2.http.GET
import retrofit2.http.Path
import retrofit2.http.Query

/**
 * Created by feb on 19/03/2017.
 */
interface ForumService {
    @GET("{language}/community/forumdisplay.php")
    fun category(@Path("language") language: String, @Query("f") categoryId: Int): Observable<String>

    @GET("{language}/community/showthread.php")
    fun thread(@Path("language") language: String, @Query("t") threadId: Int, @Query("page") page: Int): Observable<String>

    @GET("{language}/community/devtracker.php")
    fun devTracker(@Path("language") language: String, @Query("page") page: Int): Observable<String>
}
