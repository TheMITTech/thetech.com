CKEDITOR.editorConfig = (config) ->
  config.contentsCss = '/contents.css'

  config.extraAllowedContent = '*[data*]';

  config.toolbarGroups = [
    { name: 'basicstyles', groups: [ 'basicstyles', 'cleanup' ] },
    { name: 'paragraph',   groups: [ 'list', 'blocks' ] },
    { name: 'links' },
    { name: 'styles' },
    { name: 'tools' },
  ];

  config.removeButtons = 'Cut,Copy,Paste,Undo,Redo,Anchor,Underline,Strike,Subscript,Superscript,Font,FontSize,CreateDiv,Styles';

  config.removeDialogTabs = 'link:advanced';

  config.height = '1008px';

  config.format_tags = 'body;subsection_heading;correction'
  config.format_correction =
    name: 'Correction'
    element: 'p'
    attributes:
      class: 'correction'
  config.format_body =
    name: 'Body'
    element: 'p'
  config.format_subsection_heading =
    name: 'Subsection Heading'
    element: 'h3'
