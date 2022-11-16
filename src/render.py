from jinja2 import Environment, FileSystemLoader

MACRO_DIR = "macros"


def _get_template_render(path: str, **kwargs) -> str:
    """
    Render a Jinja2 template to actual text, using macros in scope.
    :param path: Path to the file you'd like to render.
    """
    env = Environment(loader=FileSystemLoader(MACRO_DIR))
    render = env.from_string(open(path, 'r').read()).render(**kwargs)
    return render


def render_sql_template(model_path: str, **kwargs) -> str:
    return _get_template_render(model_path, **kwargs)


if __name__ == '__main__':
    render = render_sql_template('models/1_azimutes.sql', bus_line='020', file_year='2019', file_month='05',
                                 file_day='03')

    # with open('out.sql', 'w') as f:
    #     f.write(render)
    print(render)
