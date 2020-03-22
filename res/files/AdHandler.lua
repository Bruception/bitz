
local lg = love.graphics

AdHandler = {}

function AdHandler:load()

  --ca-app-pub-2876873675473263/2376784508  -- release
  -- ca-app-pub-3940256099942544/4411468910 -- test
  self.AD_INTERSTITIAL_ID = "ca-app-pub-2876873675473263/2376784508"

  -- ca-app-pub-2876873675473263/3031177627 -- release
  -- ca-app-pub-3940256099942544/6300978111 -- test
  self.AD_BANNER_ID = "ca-app-pub-2876873675473263/3031177627"

  self.interReady = false
  self.interTimer = 0
  self.interSteps = 0
  self.presenting = false

  if(IOS) then
    self:requestInterstitial()
  end
end

function AdHandler:update(dt)
  if(self.interSteps >= 3) then

    if(self.interReady) then
      self.interTimer = self.interTimer + dt
      if(self.interTimer >= 1) then
        self.interReady = false

        if(self:isInterstitialLoaded()) then
          self:showInterstitial()
          self.presenting = true
        else
          self.presenting = false
        end

      end
    end

    if(self.interTimer >= 1 and self.presenting and self:interstitialClosed()) then
      self:requestInterstitial()
      self.interTimer = 0
      self.interSteps = 0
      self.presenting = false
    elseif(self.interTimer >= 1 and not self.presenting) then
      self:requestInterstitial()
      self.interTimer = 0
      self.interSteps = 0
    end

  end
end
function AdHandler:requestInterstitial()
  love.ads.requestInterstitial(self.AD_INTERSTITIAL_ID)
end

function AdHandler:showInterstitial()
  love.ads.showInterstitial()
end

function AdHandler:isInterstitialLoaded()
  return love.ads.isInterstitialLoaded()
end

function AdHandler:interstitialClosed()
  return love.ads.coreInterstitialClosed()
end

function AdHandler:initInterstitial()
  if(self.interSteps >= 3) then
    self.interReady = true
  end
end
