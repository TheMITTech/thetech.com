CKEDITOR.editorConfig = (config) ->
  config.extraAllowedContent = 'img[src,alt,width,height]';

  config.toolbarGroups = [
    { name: 'editing',     groups: [ 'find', 'selection', 'spellchecker' ] },
    { name: 'basicstyles', groups: [ 'basicstyles', 'cleanup' ] },
    { name: 'paragraph',   groups: [ 'list', 'blocks', 'align' ] },
    { name: 'links' },
    { name: 'styles' },
    { name: 'colors' },
    { name: 'tools' },
  ];

  config.removeButtons = 'Cut,Copy,Paste,Undo,Redo,Anchor,Underline,Strike,Subscript,Superscript,Font,Size,CreateDiv,Styles';

  config.removeDialogTabs = 'link:advanced';

  config.height = '400px';
