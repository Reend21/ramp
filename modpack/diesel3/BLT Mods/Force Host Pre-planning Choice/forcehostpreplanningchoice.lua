local PrePlanningManager__update_majority_votes_orig = PrePlanningManager._update_majority_votes

function PrePlanningManager:_update_majority_votes(...)
  if Network:is_client() then
    return PrePlanningManager__update_majority_votes_orig(self, ...)
  end
  -- Modified version of original _update_majority_votes, it selects your choosed plan_data and makes it always the winner by default
  local local_peer_id = managers.network:session():local_peer():id()
  local vote_council = self:get_vote_council()
  local winners = {}
  local plan_data = vote_council[local_peer_id]

  --Since hotline miami heist's plan_data might be nil
    if plan_data then
        local winners = {}
        for plan, data in pairs( plan_data ) do
            winners[plan] = { data[1], data[2] }
        end
        self._saved_majority_votes = winners
        return winners
    end

    -- If plan_data is nil, just call original method to handle this
    return PrePlanningManager__update_majority_votes_orig(self, ...)
end