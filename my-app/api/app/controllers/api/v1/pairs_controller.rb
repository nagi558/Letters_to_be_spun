module Api
  module V1
    class PairsController < ApplicationController
      before_action :authenticate_user!

      def show
        render json: pair_json, status: :ok
      end

      def invite
        return render json: { errors: ['すでにパートナーと接続済みです'] }, status: :unprocessable_content if current_user.paired?

        pair = Pair.create!
        pair.pair_memberships.create!(user: current_user)
        pair.generate_invitation_token!

        render json: {
          invitation_url: "#{ENV.fetch('FRONTEND_URL', nil)}/invite/##{pair.invitation_token}"
        }, status: :created
      end

      def verify_token
        pair = find_valid_pair(params[:token])
        return render json: { errors: ['招待URLが無効または期限切れです'] }, status: :not_found unless pair

        if pair.users.include?(current_user)
          return render json: { errors: ['自分自身の招待URLには参加できません'] },
                        status: :unprocessable_content
        end

        partner = pair.users.first
        render json: { partner_name: partner&.nickname || partner&.name }, status: :ok
      end

      def join
        return render json: { errors: ['すでにパートナーと接続済みです'] }, status: :unprocessable_content if already_connected?

        pair = find_valid_pair(params[:token])
        return render json: { errors: ['招待URLが無効または期限切れです'] }, status: :not_found unless pair

        if pair.users.include?(current_user)
          return render json: { errors: ['自分自身の招待URLには参加できません'] },
                        status: :unprocessable_content
        end

        complete_join(pair)
        render json: pair_json, status: :ok
      end

      def destroy
        unless current_user.paired? || current_user.pending?
          return render json: { errors: ['接続中のパートナーがいません'] }, status: :not_found
        end

        current_user.pair.destroy
        render json: { message: 'パートナー接続を解除しました' }, status: :ok
      end

      private

      def already_connected?
        current_user.paired? || current_user.pending?
      end

      def complete_join(pair)
        pair.pair_memberships.create!(user: current_user)
        pair.update!(invitation_token: nil, invitation_token_expires_at: nil)
        current_user.reload
      end

      def find_valid_pair(token)
        pair = Pair.find_by(invitation_token: token)
        return nil unless pair&.invitation_token_valid?

        pair
      end

      def pair_json
        return paired_json if current_user.paired?
        return pending_json if current_user.pending?

        unpaired_json
      end

      def paired_json
        {
          paired: true,
          pending: false,
          partner_name: current_user.partner&.nickname || current_user.partner&.name,
          invitation_url: nil
        }
      end

      def pending_json
        {
          paired: false,
          pending: true,
          partner_name: nil,
          invitation_url: "#{ENV.fetch('FRONTEND_URL', nil)}/invite/#{current_user.pair.invitation_token}"
        }
      end

      def unpaired_json
        { paired: false, pending: false, partner_name: nil, invitation_url: nil }
      end
    end
  end
end
