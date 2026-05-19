import { useEffect, useState } from "react"
import { useNavigate, useParams } from "react-router-dom"
import axiosInstance from "@/lib/axios"
import type { Post, Category } from "@/types"
import axios from "axios"

export const CategoryPostList = () => {
  const { id } = useParams()
  const [posts, setPosts] = useState<Post[]>([])
  const [category, setCategory] = useState<Category | null>(null)
  const [error, setError] = useState<string | null>(null)
  const navigate = useNavigate()

  useEffect(() => {
    const controller = new AbortController()
    const fetchCategoryPosts = async () => {
      try {
        const response = await axiosInstance.get(
          `/api/v1/categories/${id}/posts`,
          { signal: controller.signal },
        )
        setCategory(response.data.category)
        setPosts(response.data.posts)
      } catch (e) {
        if (axios.isCancel(e)) return
        console.error(e)
        setError("データの取得に失敗しました")
      }
    }
    fetchCategoryPosts()
    return () => controller.abort()
  }, [id])

  return (
    <div className="min-h-full bg-[#E8EEF1] pb-20">
      <div className="max-w-2xl mx-auto pt-6 px-4">
        <div className="bg-white rounded-2xl shadow-sm p-6">
          {/* タイトル */}
          <div className="flex justify-between items-center mb-3">
            <h1 className="text-[38px] font-bold tracking-normal text-[#444444] text-center mb-8 font-sans pt-7">
              {category?.name}
            </h1>
          </div>

          {error && (
            <div className="mb-4 p-3 bg-red-100 text-red-700 rounded">
              {error}
            </div>
          )}

          {/* 投稿一覧 */}
          {posts.length === 0 ? (
            <div className="text-center text-gray-400 mt-10">
              <p>このカテゴリにはまだ投稿がありません</p>
            </div>
          ) : (
            <div className="flex flex-col gap-4">
              {posts.map((post) => (
                <div
                  key={post.id}
                  className="bg-white rounded-2xl shadow-lg p-5 flex justify-between items-start"
                >
                  <div className="flex-1">
                    <div className="flex items-center gap-2 mb-3">
                      <p className="text-gray-800 font-bold text-lg">
                        {post.title}
                      </p>
                      <span className="text-xs text-white bg-[#A0B9C6] px-2 py-1 rounded-full">
                        {category?.name}
                      </span>
                    </div>
                    <p className="text-gray-500 text-sm text-left">
                      {post.body}
                    </p>
                  </div>
                </div>
              ))}
            </div>
          )}

          {/* 戻るボタン */}
          <div className="flex justify-end mt-6">
            <button
              onClick={() => navigate("/categories")}
              className="text-sm font-bold text-white bg-[#4f8196] hover:bg-[#80949e] px-4 py-2 rounded-lg transition duration-200"
            >
              ← 戻る
            </button>
          </div>
        </div>
      </div>
    </div>
  )
}
