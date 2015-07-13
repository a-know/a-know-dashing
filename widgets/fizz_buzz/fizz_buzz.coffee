class Dashing.FizzBuzz extends Dashing.Widget

  ready: ->
    # ここは初期化時に実行したいエフェクトを書く

  onData: (data) ->
    $(@node).fadeOut().fadeIn()