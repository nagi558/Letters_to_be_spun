require 'rails_helper'

RSpec.describe 'Api::V1::Pairs', type: :request do
  let(:user)    { create(:user) }
  let(:partner) { create(:user) }
  let(:headers) { auth_headers(user) }

  def json
    response.parsed_body
  end

  describe 'GET /api/v1/pair' do
    context '認証済みの場合' do
      context 'Pair未接続の場合' do
        it 'paired: false を返す' do
          get '/api/v1/pair', headers: headers
          expect(response).to have_http_status(:ok)
          expect(json['paired']).to be(false)
        end
      end

      context 'Pair接続済みの場合' do
        let!(:pair) { create(:pair, :with_members, owner: user, member: partner) }

        it 'paired: true とパートナー名を返す' do
          get '/api/v1/pair', headers: headers
          expect(response).to have_http_status(:ok)
          expect(json['paired']).to be(true)
          expect(json['partner_name']).to eq(partner.nickname || partner.name)
        end
      end
    end

    context 'Pair招待中（pending）の場合' do
      let!(:pair) { create(:pair, :with_invitation_token) }
      let!(:_membership) { create(:pair_membership, pair: pair, user: user) }

      it 'pending: true を返す' do
        get '/api/v1/pair', headers: headers
        expect(response).to have_http_status(:ok)
        expect(json['paired']).to be(false)
        expect(json['pending']).to be(true)
      end

      it 'invitation_urlを返す' do
        get '/api/v1/pair', headers: headers
        expect(json['invitation_url']).to be_present
      end
    end

    context '未認証の場合' do
      it '401を返す' do
        get '/api/v1/pair'
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'POST /api/v1/pair/invite' do
    context '認証済みの場合' do
      context 'Pair未接続の場合' do
        it '招待URLを返す' do
          post '/api/v1/pair/invite', headers: headers
          expect(response).to have_http_status(:created)
          expect(json['invitation_url']).to be_present
        end

        it 'Pairが作成される' do
          expect do
            post '/api/v1/pair/invite', headers: headers
          end.to change(Pair, :count).by(1)
        end

        it 'PairMembershipが1つだけ作成される' do
          expect do
            post '/api/v1/pair/invite', headers: headers
          end.to change(PairMembership, :count).by(1)
        end
      end

      context 'Pair接続済みの場合' do
        let!(:pair) { create(:pair, :with_members, owner: user, member: partner) }

        it '422を返す' do
          post '/api/v1/pair/invite', headers: headers
          expect(response).to have_http_status(:unprocessable_entity)
          expect(json['errors']).to be_present
        end
      end
    end

    context '未認証の場合' do
      it '401を返す' do
        post '/api/v1/pair/invite'
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'GET /api/v1/pair/join/:token' do
    let!(:pair) { create(:pair, :with_invitation_token) }
    let!(:_membership) { create(:pair_membership, pair: pair, user: partner) }

    context '認証済みの場合' do
      context '有効なトークンの場合' do
        it '200とパートナー名を返す' do
          get "/api/v1/pair/join/#{pair.invitation_token}", headers: headers
          expect(response).to have_http_status(:ok)
          expect(json['partner_name']).to eq(partner.nickname || partner.name)
        end
      end

      context '存在しないトークンの場合' do
        it '404を返す' do
          get '/api/v1/pair/join/invalidtoken', headers: headers
          expect(response).to have_http_status(:not_found)
        end
      end

      context '期限切れのトークンの場合' do
        let(:pair) { create(:pair, :with_expired_token) }

        it '404を返す' do
          get "/api/v1/pair/join/#{pair.invitation_token}", headers: headers
          expect(response).to have_http_status(:not_found)
        end
      end

      context '自分が発行したトークンの場合' do
        let!(:_membership) { create(:pair_membership, pair: pair, user: user) }

        it '422を返す' do
          get "/api/v1/pair/join/#{pair.invitation_token}", headers: headers
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    context '未認証の場合' do
      it '401を返す' do
        get "/api/v1/pair/join/#{pair.invitation_token}"
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'POST /api/v1/pair/join/:token' do
    let(:pair) { create(:pair, :with_invitation_token) }
    let!(:_membership) { create(:pair_membership, pair: pair, user: partner) }

    context '認証済みの場合' do
      context '有効なトークンの場合' do
        it '200を返す' do
          post "/api/v1/pair/join/#{pair.invitation_token}", headers: headers
          expect(response).to have_http_status(:ok)
          expect(json['paired']).to be(true)
        end

        it 'PairMembershipが1つだけ作成される' do
          expect do
            post "/api/v1/pair/join/#{pair.invitation_token}", headers: headers
          end.to change(PairMembership, :count).by(1)
        end

        it 'invitation_tokenが無効化される' do
          post "/api/v1/pair/join/#{pair.invitation_token}", headers: headers
          expect(pair.reload.invitation_token).to be_nil
        end

        it 'invitation_token_expires_atが無効化される' do
          post "/api/v1/pair/join/#{pair.invitation_token}", headers: headers
          expect(pair.reload.invitation_token_expires_at).to be_nil
        end
      end

      context 'Pair接続済みの場合' do
        let!(:_existing_pair) { create(:pair, :with_members, owner: user, member: create(:user)) }

        it '422を返す' do
          post "/api/v1/pair/join/#{pair.invitation_token}", headers: headers
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'PairMembershipが増えない' do
          expect do
            post "/api/v1/pair/join/#{pair.invitation_token}", headers: headers
          end.not_to change(PairMembership, :count)
        end
      end

      context '自分が発行したトークンの場合' do
        let!(:_membership) { create(:pair_membership, pair: pair, user: user) }

        it '422を返す' do
          post "/api/v1/pair/join/#{pair.invitation_token}", headers: headers
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      context '期限切れのトークンの場合' do
        let(:pair) { create(:pair, :with_expired_token) }

        it '404を返す' do
          post "/api/v1/pair/join/#{pair.invitation_token}", headers: headers
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context '未認証の場合' do
      it '401を返す' do
        post "/api/v1/pair/join/#{pair.invitation_token}"
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'DELETE /api/v1/pair' do
    context '認証済みの場合' do
      context 'Pair接続済みの場合' do
        let!(:pair) { create(:pair, :with_members, owner: user, member: partner) }

        it '200を返す' do
          delete '/api/v1/pair', headers: headers
          expect(response).to have_http_status(:ok)
        end

        it 'Pairが削除される' do
          expect do
            delete '/api/v1/pair', headers: headers
          end.to change(Pair, :count).by(-1)
        end

        it '両方のPairMembershipが削除される' do
          expect do
            delete '/api/v1/pair', headers: headers
          end.to change(PairMembership, :count).by(-2)
        end

        it 'パートナー側のMembershipも削除される' do
          delete '/api/v1/pair', headers: headers
          expect(PairMembership.exists?(user: partner)).to be(false)
        end
      end

      context 'Pair未接続の場合' do
        it '404を返す' do
          delete '/api/v1/pair', headers: headers
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context 'Pair招待中（pending）の場合' do
      let!(:pair) { create(:pair, :with_invitation_token) }
      let!(:_membership) { create(:pair_membership, pair: pair, user: user) }

      it '200を返す' do
        delete '/api/v1/pair', headers: headers
        expect(response).to have_http_status(:ok)
      end

      it 'Pairが削除される' do
        expect do
          delete '/api/v1/pair', headers: headers
        end.to change(Pair, :count).by(-1)
      end
    end

    context '未認証の場合' do
      it '401を返す' do
        delete '/api/v1/pair'
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
