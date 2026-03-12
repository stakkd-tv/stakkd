class Credits
  def initialize(person)
    @person = person
  end

  def as_cast_member
    return @as_cast_member if @as_cast_member
    cast_credits = @person.cast_credits.includes(record: [:show, :season, :episodes])
    @as_cast_member ||= grouped_by_year(cast_credits).map do |year, credits|
      {
        year: year,
        credits: credits_by_parent(credits, count_by: :character)
      }
    end.sort_by { -(it[:year] || 10_000) }
  end

  def as_crew_member
    return @as_crew_member if @as_crew_member
    crew_credits = @person.crew_credits.includes(:job, record: [:show, :season, :episodes])
    @as_crew_member ||= grouped_by_year(crew_credits).map do |year, credits|
      {
        year: year,
        credits: credits_by_parent(credits, count_by: :job)
      }
    end.sort_by { -(it[:year] || 10_000) }
  end

  def credit_types
    [
      as_cast_member.any? ? "cast" : nil,
      as_crew_member.any? ? "crew" : nil
    ].compact
  end

  private

  def grouped_by_year(credits)
    credits.group_by { |credit| credit_year(credit) }
  end

  def credit_year(credit)
    # A season can span multiple years. If this credit is an individual season regular then all the credits will
    # be attributed to the year of the season, not the individual episodes part of that season. This is the
    # intended behaviour.
    #
    # We treat nil years in this case as a upcoming/TBA date. This works for cast members on a move/show/season
    # level. However in some cases, a person may be a guest star on an episode that has a nil air date.
    # In cases like that, a nil air date does not necessarily mean the episode is upcoming, it could also
    # mean that the episode was never actually aired (this is the case for a lot of special episodes).
    # Therefore, we fallback to the seasons air date - if that is set it means that this episode isn't
    # likely to be an upcoming episode, but if it's not set then it likely is an upcoming episode (as no episodes
    # in the season have aired yet).

    if episode_without_year?(credit)
      credit.record.season.year
    else
      credit.record.year
    end
  end

  def episode_without_year?(credit)
    credit.record.is_a?(Episode) && credit.record.year.nil?
  end

  def credits_by_parent(credits, count_by:)
    credits
      .group_by { |credit| parent_record(credit) }
      .transform_values { |group| (count_by == :character) ? credits_by_character(group) : credits_by_job(group) }
  end

  def parent_record(credit)
    record = credit.record

    if record.is_a?(Season) || record.is_a?(Episode)
      record.show
    else
      record
    end
  end

  def credits_by_character(credits)
    credits
      .group_by(&:character)
      .transform_values { |values| values.sum { |credit| episode_count(credit) } }
  end

  def credits_by_job(credits)
    credits
      .group_by { |credit| credit.job.name }
      .transform_values { |values| values.sum { |credit| episode_count(credit) } }
  end

  def episode_count(credit)
    record = credit.record

    if record.is_a?(Episode) || record.is_a?(Movie)
      1
    else
      record.episodes.size
    end
  end
end
