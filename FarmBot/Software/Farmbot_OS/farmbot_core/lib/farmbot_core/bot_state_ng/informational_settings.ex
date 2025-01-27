defmodule FarmbotCore.BotStateNG.InformationalSettings do
  @moduledoc false
  alias FarmbotCore.BotStateNG.InformationalSettings
  use Ecto.Schema
  import Ecto.Changeset

  alias FarmbotCore.Project

  @primary_key false

  embedded_schema do
    field(:target, :string, default: to_string(Project.target()))
    field(:env, :string, default: to_string(Project.env()))
    field(:controller_version, :string, default: Project.version())
    field(:firmware_commit, :string, default: Project.arduino_commit())
    field(:commit, :string, default: Project.commit())
    field(:firmware_version, :string)
    field(:node_name, :string)
    field(:soc_temp, :integer)
    field(:throttled, :string)
    field(:wifi_level, :integer)
    field(:wifi_level_percent, :integer)
    field(:uptime, :integer)
    field(:memory_usage, :integer)
    field(:disk_usage, :integer)
    field(:sync_status, :string, default: "sync_now")
    field(:locked, :boolean, default: false)
    field(:last_status, :string)
    field(:cache_bust, :integer)
    field(:busy, :boolean)
    field(:idle, :boolean)
    field(:update_available, :boolean, default: false)
  end

  def new do
    %InformationalSettings{}
    |> changeset(%{})
    |> apply_changes()
  end

  def view(informational_settings) do
    %{
      target: informational_settings.target,
      env: informational_settings.env,
      controller_version: informational_settings.controller_version,
      firmware_commit: informational_settings.firmware_commit,
      commit: informational_settings.commit,
      firmware_version: informational_settings.firmware_version,
      node_name: informational_settings.node_name,
      soc_temp: informational_settings.soc_temp,
      throttled: informational_settings.throttled,
      wifi_level: informational_settings.wifi_level,
      wifi_level_percent: informational_settings.wifi_level_percent,
      uptime: informational_settings.uptime,
      memory_usage: informational_settings.memory_usage,
      disk_usage: informational_settings.disk_usage,
      sync_status: informational_settings.sync_status,
      locked: informational_settings.locked,
      last_status: informational_settings.last_status,
      cache_bust: informational_settings.cache_bust,
      busy: informational_settings.busy,
      idle: informational_settings.idle,
      update_available: informational_settings.update_available
    }
  end

  def changeset(informational_settings, params \\ %{}) do
    informational_settings
    |> cast(params, [
      :target,
      :env,
      :controller_version,
      :firmware_commit,
      :commit,
      :firmware_version,
      :node_name,
      :soc_temp,
      :throttled,
      :wifi_level,
      :wifi_level_percent,
      :uptime,
      :memory_usage,
      :disk_usage,
      :sync_status,
      :locked,
      :last_status,
      :cache_bust,
      :busy,
      :idle,
      :update_available
    ])
  end
end
