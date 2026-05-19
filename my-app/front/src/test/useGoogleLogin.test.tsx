import { renderHook, act } from "@testing-library/react"
import { BrowserRouter } from "react-router-dom"
import { useGoogleLogin } from "@/hooks/useGoogleLogin"
import axiosInstance from "@/lib/axios"
import { tokenStorage } from "@/lib/tokenStorage"
import type { ReactNode } from "react"

vi.mock("@/lib/axios")
vi.mock("@/lib/tokenStorage")

const loginMock = vi.fn()
vi.mock("@/context/AuthContext", () => ({
  useAuth: () => ({ login: loginMock }),
}))

const wrapper = ({ children }: { children: ReactNode }) => (
  <BrowserRouter>{children}</BrowserRouter>
)

describe("useGoogleLogin", () => {
  afterEach(() => {
    vi.restoreAllMocks()
    vi.clearAllMocks()
  })

  describe("handleCredentialResponse", () => {
    describe("APIが成功した場合", () => {
      beforeEach(() => {
        vi.mocked(axiosInstance.post).mockResolvedValue({
          headers: {
            "access-token": "test-token",
            client: "test-client",
            uid: "test@gmail.com",
          },
          data: {
            data: { email: "test@gmail.com", name: "テストユーザー" },
          },
        })

        vi.mocked(axiosInstance.get).mockResolvedValue({
          data: { has_seen_guide: false },
        })
      })

      it("/api/v1/auth/googleにid_tokenをPOSTする", async () => {
        const { result } = renderHook(() => useGoogleLogin(), { wrapper })

        await act(async () => {
          await result.current.handleCredentialResponse({
            credential: "test-credential",
          })
        })

        expect(axiosInstance.post).toHaveBeenCalledWith("/api/v1/auth/google", {
          id_token: "test-credential",
        })
      })

      it("tokenStorageにトークンを保存する", async () => {
        const { result } = renderHook(() => useGoogleLogin(), { wrapper })

        await act(async () => {
          await result.current.handleCredentialResponse({
            credential: "test-credential",
          })
        })

        expect(tokenStorage.set).toHaveBeenCalledWith({
          accessToken: "test-token",
          client: "test-client",
          uid: "test@gmail.com",
        })
      })

      it("login()が呼ばれる", async () => {
        const { result } = renderHook(() => useGoogleLogin(), { wrapper })

        await act(async () => {
          await result.current.handleCredentialResponse({
            credential: "test-credential",
          })
        })

        expect(loginMock).toHaveBeenCalled()
      })
    })

    describe("APIが失敗した場合", () => {
      beforeEach(() => {
        vi.mocked(axiosInstance.post).mockRejectedValue(new Error("API Error"))
      })

      it("tokenStorageに保存しない", async () => {
        vi.spyOn(console, "error").mockImplementation(() => {})
        const { result } = renderHook(() => useGoogleLogin(), { wrapper })

        await act(async () => {
          await result.current.handleCredentialResponse({
            credential: "test-credential",
          })
        })

        expect(tokenStorage.set).not.toHaveBeenCalled()
      })

      it("login()が呼ばれない", async () => {
        vi.spyOn(console, "error").mockImplementation(() => {})
        const { result } = renderHook(() => useGoogleLogin(), { wrapper })

        await act(async () => {
          await result.current.handleCredentialResponse({
            credential: "test-credential",
          })
        })

        expect(loginMock).not.toHaveBeenCalled()
      })

      it("エラーログが出力される", async () => {
        const consoleSpy = vi
          .spyOn(console, "error")
          .mockImplementation(() => {})
        const { result } = renderHook(() => useGoogleLogin(), { wrapper })

        await act(async () => {
          await result.current.handleCredentialResponse({
            credential: "test-credential",
          })
        })

        expect(consoleSpy).toHaveBeenCalledWith(
          "Googleログイン失敗:",
          expect.any(Error),
        )
      })
    })
  })

  describe("initializeGoogleLogin", () => {
    it("window.google.accounts.id.initializeを正しい引数で呼ぶ", () => {
      const mockInitialize = vi.fn()
      vi.stubGlobal("google", {
        accounts: { id: { initialize: mockInitialize } },
      })

      const { result } = renderHook(() => useGoogleLogin(), { wrapper })
      act(() => {
        result.current.initializeGoogleLogin()
      })

      expect(mockInitialize).toHaveBeenCalledWith(
        expect.objectContaining({
          client_id: expect.any(String),
          callback: expect.any(Function),
        }),
      )

      vi.unstubAllGlobals()
    })
  })
})
