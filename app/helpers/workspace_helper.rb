module WorkspaceHelper
  def idle_wips
    @wips.find_all { |w| w.state == :idle }
  end
end
